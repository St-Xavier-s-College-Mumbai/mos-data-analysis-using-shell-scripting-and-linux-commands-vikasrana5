#!/bin/bash

# Define paths relative to script's location
input_file="../data/access.log"
output_file="../data/clean_log.tsv"

# Ensure input file exists
if [[ ! -f "$input_file" ]]; then
    echo "❌ ERROR: '$input_file' not found."
    exit 1
fi

# Create the output directory if not exists
mkdir -p ../data

# Clean and convert log to TSV format
{
  echo -e "IP_Address\tDate_Time\tRequest_Method\tRequested_Resource\tStatus_Code\tBytes_Sent"
  cat "$input_file" |
    sed 's/\[//g; s/\]//g' |
    tr -d '"' |
    awk '{print $1 "\t" $4 "\t" $6 "\t" $7 "\t" $9 "\t" $10}'
} > "$output_file"

echo "✅ Cleaned log saved to $output_file"
