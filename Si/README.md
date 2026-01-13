# dvrk-cannulas

CAD models for da Vinci Si custom cannulas.

## Intro

This repo includes an openscad file for Si cannulas (https://openscad.org/).  This file can be modified to generate different shapes.  You should always open the source file with `openscad`, check the parameters you want, render (F6) and then export as STL.  Some STL files are provided, but they don't cover all the possibilities.

## Parameters

* **`inner_d`**: Inner diameter of the cannula. Default is 8.7mm (for 8mm instruments). Other common values: 10.7mm, 14.35mm.
* **`include_bottom`**: Set to `true` to include the bottom tube (cannula), or `false` to remove it.
* **`cut_in_half`**: Set to `true` to cut the model in half, creating two mating parts. Useful for instruments with sensors attached near the tip (when inner diameter is too small to insert instrument)