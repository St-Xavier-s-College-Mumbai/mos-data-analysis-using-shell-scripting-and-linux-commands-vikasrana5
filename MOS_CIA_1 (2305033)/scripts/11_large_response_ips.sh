#!/bin/bash

# Paths
input_file="../data/clean_log.tsv"
tsv_file="../visualizations/11_large_response_ips.tsv"
png_file="../visualizations/11_large_response_ips.png"

# Create visualizations directory if not present
mkdir -p ../visualizations

# Step 1: Extract top 5 IPs with responses > 30000 bytes
awk -F'\t' 'NR>1 && $6 > 30000 {print $1}' "$input_file" \
  | sort | uniq -c | sort -nr | head -5 \
  | awk '{print $2 "\t" $1}' > "$tsv_file"

echo "✅ Top large-response IPs saved to $tsv_file"

# Step 2: Generate Donut Chart using Gnuplot
gnuplot <<-EOF
reset
set terminal pngcairo size 800,600
set output "$png_file"
unset border
unset tics
unset key
set size square
set xrange [-1.5:1.5]
set yrange [-1.5:1.5]

# Read data into arrays
stats "$tsv_file" using 2 nooutput
n = STATS_records
array labels[n]
array counts[n]
array colors[n] = ["#FF9999", "#66CCFF", "#99FF66", "#FFCC66", "#CC99FF"]

do for [i=1:n] {
    labels[i] = system(sprintf("awk 'NR==%d {print \$1}' %s", i, "$tsv_file"))
    counts[i] = system(sprintf("awk 'NR==%d {print \$2}' %s", i, "$tsv_file"))
}

# Donut chart parameters
total = 0
do for [i=1:n] {
    total = total + counts[i]
}
radius_outer = 1.0
radius_inner = 0.4
start_angle = 0

do for [i=1:n] {
    angle = 360.0 * counts[i] / total
    end_angle = start_angle + angle

    # Colored pie slice
    set object i circle at 0,0 size radius_outer arc [start_angle:end_angle] \
        fillstyle solid 1.0 fillcolor rgb colors[i] front

    # Black border
    set object (i+100) circle at 0,0 size radius_outer arc [start_angle:end_angle] \
        fillstyle empty border rgb "black" lw 1 front

    # Label outside
    mid_angle = (start_angle + end_angle)/2
    label_x = 1.1 * cos(mid_angle * pi / 180)
    label_y = 1.1 * sin(mid_angle * pi / 180)
    set label i labels[i] at label_x,label_y center font ",9"

    start_angle = end_angle
}

# Donut hole
set object 999 circle at 0,0 size radius_inner fillstyle solid 1.0 fillcolor rgb "white" front
plot NaN notitle
EOF

echo "✅ Donut chart saved to $png_file"
