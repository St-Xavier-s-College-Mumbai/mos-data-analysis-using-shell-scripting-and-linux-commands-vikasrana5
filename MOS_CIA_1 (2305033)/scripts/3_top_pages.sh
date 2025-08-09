#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
png_file="../visualizations/03_top_pages_pie.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Extract top 5 requested pages and counts
mapfile -t raw_data < <(tail -n +2 "$input_file" | cut -f4 | sort | uniq -c | sort -nr | head -5)

# Separate counts and labels into arrays
counts=()
labels=()

for entry in "${raw_data[@]}"; do
    count=$(echo "$entry" | awk '{print $1}')
    page=$(echo "$entry" | awk '{$1=""; print $0}' | sed 's/^ *//')
    counts+=("$count")
    # Shorten long paths for label readability (optional tweak)
    if [[ "$page" == */jquery* ]]; then labels+=("/jquery")
    elif [[ "$page" == */index* ]]; then labels+=("/index")
    elif [[ "$page" == */screen* ]]; then labels+=("/screen")
    elif [[ "$page" == "/favicon.ico" ]]; then labels+=("/favicon")
    else labels+=("$page")
    fi
done

# Generate the Gnuplot script inline
gnuplot <<-EOF
    reset
    set terminal png size 800,600
    set output "$png_file"

    unset border
    unset tics
    unset key
    set size square
    set xrange [-1.5:1.5]
    set yrange [-1.5:1.5]

    array counts[5] = [${counts[0]}, ${counts[1]}, ${counts[2]}, ${counts[3]}, ${counts[4]}]
    array labels[5] = ["${labels[0]}", "${labels[1]}", "${labels[2]}", "${labels[3]}", "${labels[4]}"]
    array colors[5] = ["#FF9999", "#66CCFF", "#99FF66", "#FFCC66", "#CC99FF"]

    total = 0
    do for [i=1:5] {
        total = total + counts[i]
    }

    start_angle = 0
    radius = 1

    do for [i=1:5] {
        angle = 360.0 * counts[i] / total
        end_angle = start_angle + angle

        set object i circle at 0,0 size radius arc [start_angle:end_angle] \
            fillstyle solid 1.0 fillcolor rgb colors[i] behind

        set object (i+10) circle at 0,0 size radius arc [start_angle:end_angle] \
            fillstyle empty border lc rgb "black" lw 1 front

        mid_angle = (start_angle + end_angle) / 2
        label_x = 0.75 * cos(mid_angle * pi / 180)
        label_y = 0.75 * sin(mid_angle * pi / 180)
        set label i labels[i].' ('.counts[i].')' at label_x, label_y center font ",10"

        start_angle = end_angle
    }

    set object 100 circle at 0,0 size radius front lw 2.5 fillstyle empty border lc rgb "black"
    plot NaN notitle
EOF

echo "✅ Pie chart saved to $png_file"
