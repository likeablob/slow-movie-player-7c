#! /bin/sh
set -e

VID_FILE=$1
VID_DIR=vid_$(date +%s)

usage() {
  echo usage: $0 VID_FILE
  exit 1
}

echo VID_FILE=$VID_FILE

[ -z $VID_FILE ] && usage
[ ! -e $VID_FILE ] && {
  echo "VID_FILE not found."
  exit 1
}

command -v ffmpeg && command -v mogrify || {
  echo "Please install ffmpeg and ImageMagick."
  exit 1
}

mkdir $VID_DIR

# Dump frames
ffmpeg -i $VID_FILE -r 1/2 -vf scale=-1:448,crop=600:448 ${VID_DIR}/vid_%06d.png

# Reduce colors with the palette
mogrify -monitor -dither FloydSteinberg -remap epaper_7c_palette.png ${VID_DIR}/*png

# Generate .bin files
npm i
node generate-index-bin.js ${VID_DIR}

echo "Done. You can delete ./${VID_DIR}"
