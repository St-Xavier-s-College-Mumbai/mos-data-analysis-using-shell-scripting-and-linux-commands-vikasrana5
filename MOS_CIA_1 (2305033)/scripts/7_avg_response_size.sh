#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
png_file="../visualizations/08_avg_bytes_gauge.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Step 1: Calculate average response size (Bytes Sent)
avg_bytes=$(tail -n +2 "$input_file" | cut -f6 | awk '{sum+=$1} END {print sum/NR}')

echo "Average Response Size: $avg_bytes bytes"

# Step 2: Plot gauge using Gnuplot
gnuplot <<-EOF
    reset
    set terminal pngcairo size 500,300
    set output "$png_file"

    unset border
    unset xtics
    unset ytics
    unset key
    set size ratio -1
    set xrange [-1.2:1.2]
    set yrange [-0.2:1.2]

    # Draw background semicircle
    do for [a=0:180:1] {
        x = cos(a * pi / 180)
        y = sin(a * pi / 180)
        set object a+1 circle at 0,0 size 1 arc [a:a+1] fc rgb "#f0f0f0" behind
    }

    # Compute needle position
    val = $avg_bytes
    angle = 180.0 * val / 5000
    needle_x = 0.9 * cos(angle * pi / 180)
    needle_y = 0.9 * sin(angle * pi / 180)

    # Draw needle
    set arrow from 0,0 to needle_x,needle_y nohead lc rgb "red" lw 2

    # Label
    set label 1 sprintf("Avg: %.2f bytes", val) at 0,-0.15 center font ",12"

    plot NaN notitle
EOF

echo "✅ Gauge chart saved to $png_file"
