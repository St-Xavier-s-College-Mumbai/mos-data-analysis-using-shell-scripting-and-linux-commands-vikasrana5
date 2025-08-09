#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
png_file="../visualizations/11_daily_requests_pie.png"

# Ensure visualization directory exists
mkdir -p ../visualizations

# Extract top 2 request dates and counts
read count1 date1 <<< $(tail -n +2 "$input_file" | cut -f2 | cut -d: -f1 | sort | uniq -c | sort -nr | head -1)
read count2 date2 <<< $(tail -n +2 "$input_file" | cut -f2 | cut -d: -f1 | sort | uniq -c | sort -nr | head -2 | tail -1)

# Plot with Gnuplot
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

    # Data arrays
    array counts[2] = [$count1, $count2]
    array labels[2] = ["$date1", "$date2"]
    array colors[2] = ["#66C2A5", "#FC8D62"]

    total = 0
    do for [i=1:2] {
        total = total + counts[i]
    }

    start_angle = 0
    radius = 1
    do for [i=1:2] {
        angle = 360.0 * counts[i] / total
        end_angle = start_angle + angle

        # Draw pie slice
        set object i circle at 0,0 size radius arc [start_angle:end_angle] \
            fillstyle solid 1.0 border lc rgb "black" lw 1 fillcolor rgb colors[i]

        # Label
        mid_angle = (start_angle + end_angle) / 2
        label_x = 1.2 * cos(mid_angle * pi / 180)
        label_y = 1.2 * sin(mid_angle * pi / 180)
        set label i sprintf("%s\\n%d requests", labels[i], counts[i]) at label_x, label_y center font ",10"

        start_angle = end_angle
    }

    plot NaN notitle
EOF

echo "✅ Daily requests pie chart saved to $png_file"
