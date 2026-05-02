#!/bin/bash

# ===== STUDENT DETAILS (EDIT THIS) =====
TITLE="DevOps Lab Report"
AUTHOR="Satvik Raj"
SAPID="500119624"

# ===== URLs (ADD/REMOVE AS NEEDED) =====
URLS=(
  "https://username.github.io/repo/"
  "https://username.github.io/repo/exp1/"
  "https://username.github.io/repo/exp2/"
  "https://username.github.io/repo/exp3/"
)

# ===== GENERATE PDF =====
pandoc "${URLS[@]}" \
  -o output.pdf \
  --pdf-engine=xelatex \
  --toc \
  --number-sections \
  -V geometry:margin=1in \
  -M title="$TITLE" \
  -M author="$AUTHOR ($SAPID)"

echo "PDF generated: output.pdf"
