#!/bin/zsh
rm -rf "Sketch, Share, Solve.pdx/"
pdc -s ./src "Sketch, Share, Solve.pdx"
version=$(sed -n -e 's/version=//p' src/pdxinfo)
zip -r9 Sketch,\ Share,\ Solve.$version.pdx.zip Sketch,\ Share,\ Solve.pdx
rm Sketch,\ Share,\ Solve.pdx/music/*.pda
zip -r9 Sketch,\ Share,\ Solve.$version-no-music.pdx.zip Sketch,\ Share,\ Solve.pdx
