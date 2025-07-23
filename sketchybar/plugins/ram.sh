#!/usr/bin/env bash

# grab the PhysMem line from top
# e.g. "PhysMem: 12.23G used (4.41G wired), 3.36G unused."
line=$(top -l1 -s0 | awk -F'PhysMem: ' '/PhysMem/ {print $2}')

# extract "12.23G" (used) and "3.36G" (unused)
read used_g unused_g <<< $(
  echo "$line" | sed -E 's/^([0-9.]+G) used.*,\s*([0-9.]+G) unused\..*/\1 \2/'
)

# strip the "G" and add them to get total
used_val=${used_g%G}
unused_val=${unused_g%G}
total_val=$(bc <<< "scale=2; $used_val + $unused_val")

# print for SketchyBar
printf "%s / %.2fG\n" "$used_g" "$total_val"
