#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
png_file="../visualizations/04_http_methods_donut.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Step 1: Extract and count valid HTTP methods
mapfile -t raw_data < <(tail -n +2 "$input_file" | cut -f3 | grep -E "^(GET|POST|HEAD|CONNECT|PUT|OPTIONS|DELETE|PATCH)$" | sort | uniq -c)

# Separate counts and labels
counts=()
labels=()

for entry in "${raw_data[@]}"; do
    count=$(echo "$entry" | awk '{print $1}')
    method=$(echo "$entry" | awk '{print $2}')
    counts+=("$count")
    labels+=("$method")
done

# Step 2: Build Gnuplot donut chart
gnuplot <<-EOF
    reset
    set terminal pngcairo size 800,600 enhanced font "Arial,12"
    set output "$png_file"

    unset border
    unset tics
    unset key
    set size square
    set xrange [-1.6:1.6]
    set yrange [-1.6:1.6]

    array counts[${#counts[@]}] = [${counts[*]}]
    array labels[${#labels[@]}] = ["${labels[*]}"]
    array colors[3] = ["#1f77b4", "#ff7f0e", "#2ca02c"]

    total = 0
    do for [i=1:${#counts[@]}] {
        total = total + counts[i]
    }

    inner_radius = 0.5
    outer_radius = 1.0
    start_angle = 0

    do for [i=1:${#counts[@]}] {
        angle = 360.0 * counts[i] / total
        end_angle = start_angle + angle

        set object i circle at 0,0 size outer_radius arc [start_angle:end_angle] fillstyle solid 1.0 fillcolor rgb colors[i]
        set object (i+10) circle at 0,0 size inner_radius arc [start_angle:end_angle] fillstyle solid 1.0 fillcolor rgb "white"

        mid_angle = (start_angle + end_angle) / 2
        label_x = 1.2 * cos(mid_angle * pi / 180)
        label_y = 1.2 * sin(mid_angle * pi / 180)
        set label i sprintf("%s (%d)", labels[i], counts[i]) at label_x, label_y center font ",12"

        start_angle = end_angle
    }

    plot NaN notitle
EOF

echo "✅ Donut chart saved to $png_file"
