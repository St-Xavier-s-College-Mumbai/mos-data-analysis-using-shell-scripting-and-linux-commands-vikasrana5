#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/09_error_ips.tsv"
png_file="../visualizations/09_error_ips_bar.png"

# Ensure visualization directory exists
mkdir -p ../visualizations

# Step 1: Extract top 5 IPs that caused 4xx/5xx errors
echo -e "IP\tCount" > "$tsv_file"
awk -F'\t' '$5 ~ /^[45]/ {print $1}' "$input_file" | sort | uniq -c | sort -nr | head -5 | while read -r count ip; do
    echo -e "$ip\t$count" >> "$tsv_file"
done

# Step 2: Plot using Gnuplot
gnuplot <<-EOF
    reset
    set terminal png size 800,600
    set output "$png_file"
    set title "Top IPs Causing 4xx/5xx Errors"
    set style data histograms
    set style fill solid 1.0 border -1
    set boxwidth 0.5
    set grid ytics
    set ylabel "Request Count"
    set xlabel "IP Address"
    set xtics rotate by -45
    set datafile separator '\t'
    plot "$tsv_file" using 2:xtic(1) title "Requests" lc rgb "#FF5733"
EOF

echo "✅ Error IPs bar chart saved to $png_file"
