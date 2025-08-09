#!/bin/bash

# Paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/01_total_requests.tsv"
png_file="../visualizations/01_total_requests.png"

# Ensure the visualization directory exists
mkdir -p ../visualizations

# Step 1: Count total requests (excluding header)
total_requests=$(tail -n +2 "$input_file" | wc -l)
echo "Total Requests: $total_requests"

# Step 2: Create TSV file for plotting
echo -e "Metric\tValue" > "$tsv_file"
echo -e "Total Requests\t$total_requests" >> "$tsv_file"

# Step 3: Plot using Gnuplot
gnuplot <<-EOF
    set terminal png size 600,400
    set output "$png_file"
    set title "Total Number of Requests"
    set style data histograms
    set style fill solid
    set boxwidth 0.5
    set ylabel "Request Count"
    set xlabel "Metric"
    set datafile separator "\t"
    plot "$tsv_file" using 2:xtic(1) title "Requests"
EOF

echo "✅ Plot saved to $png_file"
