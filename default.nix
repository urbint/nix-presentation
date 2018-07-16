{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs.haskellPackages) pandoc;
in
  pkgs.stdenv.mkDerivation {
    name = "slides";
    src = ./SLIDES.md;
    buildCommand = ''
      export PATH=$PATH:${pandoc}/bin/
      mkdir -p $out/static
      pandoc -t revealjs -s -o slides.html $src -V revealjs-url=http://lab.hakim.se/reveal-js
      cp slides.html $out/static/
    '';
  }
