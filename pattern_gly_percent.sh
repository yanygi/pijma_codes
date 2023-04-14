#!/bin/bash
fasta_file=$1
output_file=$2
tmp_file=$(mktemp)

while read -r header; do
  read -r sequence

  # Get the total number of G, A, and sequence length
  g_count=$(grep -o "G" <<< "$sequence" | wc -l)
  a_count=$(grep -o "A" <<< "$sequence" | wc -l)
  length=${#sequence}

  # Check if the percentage of G and A meet the requirement
  g_percent=$(echo "scale=2; $g_count/$length * 100" | bc)
  a_percent=$(echo "scale=2; $a_count/$length * 100" | bc)
  if (( $(echo "$g_percent >= 30" | bc -l) )) && (( $(echo "$a_percent >= 10" | bc -l) )); then
    # Use regex to match the two patterns
    pattern_1='(G[GAT][A-Z])|(GG[GAT])'
    pattern_2='(A[CGT][A-Z])|(AA[CGT])'
    pattern="($pattern_1)|($pattern_2)"

    # Get all matches of the pattern in the sequence
    matches=$(grep -Eo "$pattern" <<< "$sequence" | wc -l)

    # Check if the number of matching patterns meets the requirement
    if (( "$matches" >= 5 )); then
      echo "$header" >> "$tmp_file"
      echo "$sequence" >> "$tmp_file"
    fi
  fi
done < "$fasta_file"

# Write the filtered sequences to the output file
cat "$tmp_file" > "$output_file"

# Remove the temp file
rm "$tmp_file"
