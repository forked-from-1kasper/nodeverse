#!/usr/bin/env bash
# This is a Bash script
# Use it after creating file 'atlas.png'; see 'generate.scm' for steps
# First of all, this script requires ImageMagick to be installed
# Install it if necessary (e.g. by running 'sudo apt-get install imagemagick')
# Open a terminal and go into this same directory
# Type 'bash split.sh', with no quotes, and press enter

convert -crop 8x1 atlas.png palette%d.png
mv palette0.png     palette_water1.png
mv palette1.png     palette_water2.png
mv palette2.png     palette_water3.png
mv palette3.png     palette_water4.png
