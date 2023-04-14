#!/bin/bash

# Usage: search_glycine_patterns.sh input_file output_file
# Searches for glycine patterns in FASTA input file and writes matching sequences to output file.

input_file=$1
output_file=$2

# Minimum glycine percentage to accept a sequence.
min_glycine_pct=1

# Minimum number of glycine patterns to accept a sequence.
min_glycine_patterns=3

# Patterns to search for.CxGxYCxG
patterns=('C[[:upper:]]G[[:upper:]]YC[[:upper:]]G')

# Loop over sequences in the input file.
while read -r header; read -r sequence; do
    # Count glycines in the sequence.
    glycine_count=$(echo "$sequence" | grep -o 'G' | wc -l)
    sequence_length=${#sequence}

    # Compute glycine percentage.
    glycine_pct=$(bc <<< "scale=2; $glycine_count / $sequence_length * 100")

    # Skip sequences with insufficient glycines.
    if (( $(bc <<< "$glycine_pct < $min_glycine_pct") )); then
        continue
    fi

    # Search for glycine patterns and count them.
    glycine_patterns=$(echo "$sequence" | grep -o -f <(echo "${patterns[@]}" | tr ' ' '\n') | uniq -c | awk '{print $1}')
    if (( $(bc <<< "$glycine_patterns < $min_glycine_patterns") )); then
        continue
    fi

    # Write matching sequences to output file.
    echo "$header" >> "$output_file"
    echo "$sequence" >> "$output_file"
done < "$input_file"
