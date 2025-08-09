#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/07_daily_requests.tsv"
png_file="../visualizations/07_daily_requests_line.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Step 1: Extract date from Date_Time (field 2), count requests per date
# Format: [05/Nov/2025:12:34:56 +0000] → Extract "05/Nov/2025"
tail -n +2 "$input_file" | cut -f2 | cut -d: -f1 | sort | uniq -c | awk '{print $2"\t"$1}' > "$tsv_file"

# Step 2: Plot using Gnuplot
gnuplot <<-EOF
    reset
    set terminal pngcairo size 800,600 enhanced font "Arial,12"
    set output "$png_file"

    set datafile separator '\t'
    set title "Daily Request Count"
    set xlabel "Date"
    set ylabel "Number of Requests"
    set grid

    set xdata time
    set timefmt "%d/%b/%Y"
    set format x "%d\n%b"

    plot "$tsv_file" using 1:2 with linespoints lt rgb "#2196F3" lw 2 pt 7 ps 1.5 title "Requests"
EOF

echo "✅ Daily requests line chart saved to $png_file"
