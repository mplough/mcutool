file=$1

# Get position and length of SOF0 header in file.
sof0hex=$(exiv2 -p S $file | grep SOF0 | sed 's/|.*|//')
IFS=' '
read -a sof0hexfields <<< "${sof0hex}"
offset=${sof0hexfields[0]}
length=${sof0hexfields[1]}

# Read SOF0 values into array.
sof0string=$(hexdump "$1" -s $offset -n $length -v -e '/1 "%02x "' | \
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

echo -e $"mcu_x\t$mcu_x"
echo -e $"mcu_y\t$mcu_y"
