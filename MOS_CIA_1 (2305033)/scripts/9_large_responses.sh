#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/10_top_bytes.tsv"
png_file="../visualizations/10_top_bytes_bar.png"

# Ensure visualization directory exists
mkdir -p ../visualizations

# Step 1: Extract top 5 IPs by bytes transferred
echo -e "IP\tBytes" > "$tsv_file"
tail -n +2 "$input_file" | sort -k6 -nr -t $'\t' | head -5 | awk -F'\t' '{print $1 "\t" $6}' >> "$tsv_file"

# Step 2: Plot using Gnuplot
gnuplot <<-EOF
    set terminal png size 800,600
    set output "$png_file"
    set style data histograms
    set style fill solid 1.0 border -1
    set boxwidth 0.6
    set title "Top 5 IPs by Bytes Transferred"
    set xlabel "IP Address"
    set ylabel "Bytes"
    set datafile separator '\t'
    set grid ytics
    plot "$tsv_file" using 2:xtic(1) title "Bytes" lc rgb "#4682B4"
EOF

echo "✅ Top byte responses chart saved to $png_file"
