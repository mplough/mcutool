#!/bin/bash
#
# Modified from original at
# https://quippe.eu/blog/2016/11/17/determining-minimum-coded-unit-dimensions.html
#
# Bug fixes:
# - Use proper SOF offset (past the two SOF header bytes FF C0 instead of
#   including them)
# - Pass filename as last param to hexdump (for macOS BSD hexdump)
#
# Enhancements:
# - Retrieve and display image width and height
# - Calculate and display number of MCUs

set -eu -o pipefail

file=$1

# Get position and length of SOF0 header in file.
sof0hex=$(exiv2 -p S "$file" | grep -e SOF0 -e SOF2 | sed 's/|.*|//')
IFS=' '
read -a sof0hexfields <<< "${sof0hex}"
offset=${sof0hexfields[0]}
length=${sof0hexfields[1]}

# Read SOF0 values into array.
sof0string=$(hexdump -s $((offset+2)) -n $length -v -e '/1 "%02x "' "$file" | \
             sed 's/\ $//')
read -a sof0 <<< "${sof0string}"

# Check if length of SOF0 is as expected.
sof0length=${#sof0[@]}
sof0explength=$((16#${sof0[0]}${sof0[1]}))
if [ ${#sof0[@]} -ne $((16#${sof0[0]}${sof0[1]})) ]; then
  echo "Length of SOF0 in bytes ($sof0length) not as expected ($sof0explength)."
  exit
fi

# Check if the image is a YCbCr image (the only encoding this script handles).
if [ ${sof0[7]} -ne 3 ]; then
  echo "Image has ${sof0[7]} instead of 3 components: not YCbCr."
  exit
fi
if [ ${sof0[14]} -ne 3 ]; then
  echo "Image is not YCbCr (most likely YIQ instead, or else just screwed)."
  exit
fi

# Check if Cb and Cr are both 11.
if [ ${sof0[12]} -ne 11 -o ${sof0[15]} -ne 11 ]; then
  echo "Sampling factors of Cb and/or Cr is/are not equal to 11."
  exit
fi

# Determine MCU based on Y component sampling factors:
y_hor=$(echo ${sof0[9]} | cut -c 1)
y_ver=$(echo ${sof0[9]} | cut -c 2)

mcu_x=$((y_hor * 8))
mcu_y=$((y_ver * 8))

height_y=$((16#${sof0[3]}${sof0[4]}))
width_x=$((16#${sof0[5]}${sof0[6]}))

n_full_mcu_x=$((width_x / mcu_x))
n_full_mcu_y=$((height_y / mcu_y))

n_mcu_x=$((n_full_mcu_x + (width_x % mcu_x > 0)))
n_mcu_y=$((n_full_mcu_y + (height_y % mcu_y > 0)))

n_mcus=$((n_mcu_x * n_mcu_y))

echo -e $"width\t$width_x"
echo -e $"height\t$height_y"
echo -e $"mcu_x\t$mcu_x"
echo -e $"mcu_y\t$mcu_y"
echo -e $"n_full_mcu_x\t$n_full_mcu_x"
echo -e $"n_full_mcu_y\t$n_full_mcu_y"
echo -e $"n_mcu_x\t$n_mcu_x"
echo -e $"n_mcu_y\t$n_mcu_y"
echo -e $"n_mcus\t$n_mcus"
