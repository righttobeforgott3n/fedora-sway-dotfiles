#!/bin/bash

git clone https://codeberg.org/dnkl/fnott.git
cd fnott
mkdir build && cd build
meson setup ..
ninja
sudo ninja install
