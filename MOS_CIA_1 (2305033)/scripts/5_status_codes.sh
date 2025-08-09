#!/bin/bash

# File paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/05_status_codes.tsv"
png_file="../visualizations/05_status_codes.png"

# Ensure output directory exists
mkdir -p ../visualizations

# Step 1: Extract and count status codes
echo -e "Status_Code\tCount" > "$tsv_file"
tail -n +2 "$input_file" | cut -f5 | sort | uniq -c | while read -r count code; do
    echo -e "$code\t$count" >> "$tsv_file"
done

# Step 2: Plot using Gnuplot
gnuplot <<-EOF
    reset
    set terminal png size 800,600
    set output "$png_file"

    set title "HTTP Status Code Distribution"
    set style data histograms
    set style fill solid
    set boxwidth 0.5
    set datafile separator '\t'
    set ylabel "Count"
    set xlabel "Status Code"
    set xtics rotate by -45

    plot "$tsv_file" using 2:xtic(1) title ""
EOF

echo "✅ Status code chart saved to $png_file"
