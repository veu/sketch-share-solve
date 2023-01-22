#!/bin/zsh
version=$(sed -n -e 's/version=//p' src/pdxinfo)
rm -rf Sketch,\ Share,\ Solve.pdx/
rm Sketch,\ Share,\ Solve.$version.pdx.zip Sketch,\ Share,\ Solve.$version-no-music.pdx.zip
pdc -s ./src Sketch,\ Share,\ Solve.pdx
zip -r9 Sketch,\ Share,\ Solve.$version.pdx.zip Sketch,\ Share,\ Solve.pdx
rm Sketch,\ Share,\ Solve.pdx/music/*.pda
zip -r9 Sketch,\ Share,\ Solve.$version-no-music.pdx.zip Sketch,\ Share,\ Solve.pdx
