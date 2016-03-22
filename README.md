schedulör [![](https://api.travis-ci.org/s-ol/schedulor.svg)](//travis-ci.org/s-ol/schedulor)
=========

A scheduling and tweening library.

Poor documentation lives in `doc` and [here](https://s-ol.github.io/schedulor) until I feel like it.

usage
-----

clone this repo somewhere in your lua project and require the folder where this README is located.

Example: *schedulör* is cloned in the `lib` subfolder:

    $ mkdir -p lib; cd lib
    $ git clone https://github.com/s-ol/schedulor.git
    $ cd ..; lua
    > require "lib.schedulor"

If you placed *schedulör* directly under your project root, you may need to moved `schedulor.moon` into the folder above the repo.

Currently *schedulör* is written in moonscript and distributed as such (because I write moonscript, deal-with-it).
I may distribute a Lua version at a later time, for now make sure to `require "moonscript"` before loading *schedulör*.
