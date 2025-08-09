#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/02_top_ips.tsv"
png_file="../visualizations/02_top_ips.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Step 1: Extract top 5 IPs and save as TSV
echo -e "IP_Address\tCount" > "$tsv_file"
tail -n +2 "$input_file" | cut -f1 | sort | uniq -c | sort -nr | head -5 | while read -r count ip; do
    echo -e "$ip\t$count" >> "$tsv_file"
    echo "$ip: $count"  # Print to terminal
done

# Step 2: Plot using Gnuplot
gnuplot <<-EOF
    set terminal png size 1000,600
    set output "$png_file"
    set title "Top 5 Frequent IP Addresses"
    set xlabel "IP Address"
    set ylabel "Number of Requests"
    set style data histograms
    set style fill solid border -1
    set boxwidth 0.5
    set datafile separator '\t'
    set key off
    set style line 1 lc rgb "#1F77B4"
    plot "$tsv_file" using 2:xtic(1) ls 1 title ""
EOF

echo "✅ Plot saved to $png_file"
