---
author: David Johnson
title: Nix presentation
date: July 13, 2018
---

### Nix!

---

### Nix is...
  - A purely functional package manager
    - [https://github.com/nixos/nix](https://github.com/nixos/nix)
  - An operating system distribution
    - [https://github.com/nixos/nixos](https://github.com/nixos/nixos)

---

### Nix is...
  - A pure, lazy, turing-complete, expression-oriented language
    - Can practically be considered a composable build DSL over `bash`.
      - That can be extended via the language to new package ecosystems.
  - Originally a research project
    - [https://nixos.org/~eelco/pubs/nixos-jfp-final.pdf](https://nixos.org/~eelco/pubs/nixos-jfp-final.pdf)

---

### The high-level pitch
  - Solves dependency hell
    - Packages are stored in locations based on
	  the cryptographic hash of their build inputs
	- Package hashes are calculated from:
	  - build inputs
	  - compiler flags
	  - architecture

---

### The high-level pitch
    - Example Hash
	  - nix/store/bkhx8m73wsdd4d0j74h5rbsijpajp270-pandoc-2.1.2-data
	  - SHA256 hash
	  - All packages / configuration stored in a non-standard location /nix/store

---

### The high-level pitch
  - Complete environment / dependency reproducibility on any Darwin / Linux machine.
    - Bit-for-bit down to the kernel, libc.
    -  [https://hydra.nixos.org/build/77365090#tabs-build-deps](https://hydra.nixos.org/build/77365090#tabs-build-deps)
  - Binary-cache
    - Use multiple binary caches to speed up build times
  - Large-curated community package repository
    - ruby, python, go, rust, haskell, javascript, etc.

---

## Philosophy
  - Treats builds as first class citizens of a project, not an afterthought.
  - Configuration should be explicit, not implicit (flys in face of unix philosophy).
  - Laziness is convenient

---

### Nixpkgs
  - [https://github.com/nixos/nixpkgs](https://github.com/nixos/nixpkgs)
  - Giant community curated set of expressions
  - Large eco-system of languages / tools

---

### Hydra
  - [http://hydra.nixos.org/](http://hydra.nixos.org/)
  - Public build farm accessible by all nix users
    - Runs tests for nixos
	- Distributes build artifacts

---

### Hydra
  - Harvests nixpkgs repo, builds branches which correspond to channels
  - [https://cache.nixos.org](https://cache.nixos.org) broadcasts the build
    - results of hydra publicly to all nix users

---

### NixOS
  - Applies purely functional package management to system configuration.
    - `/etc/nixos/configuration.nix`
	  - Single file declarative system-wide config
  - Allows versioning of the linux kernel.
  - Allows declarative specification of systemd units.

---

### NixOS

  - Only uses the linux kernel
  - Only uses `systemd` for process monitoring
  - Supports GCE, AWS, VirtualBox, DigitalOcean, etc.
    - Digital ocean example
	  - [https://github.com/dmjio/miso/blob/master/examples/haskell-miso.org/nix/digitalocean.nix](digital-ocean.nix)

---

### NixOS
  - `NixOS` modules
    - Search `Nixos` modules
	  - [https://nixos.org/nixos/options.html](options)
  - Copy others `NixOS` configurations
    - [https://nixos.wiki/wiki/Configuration_Collection](configurations)

---

### NixOS
  - Deploy to other NixOS machines with `nix-copy-closure`
    - Copies build-time closure of all configuration / dependencies to another machine

---

### NixOS declarative config examplep
  - [https://haskell-miso.org](https://haskell-miso.org)
    - Directory structure of "mono repo"
      - [https://github.com/dmjio/miso/tree/master/examples/haskell-miso.org](directory)
    - NixOS module declaraction (aka `systemd` unit)
	  - [https://github.com/dmjio/miso/blob/master/examples/haskell-miso.org/nix/module.nix](module.nix)
    - `NixOS` machine declaraction
	  - [https://github.com/dmjio/miso/blob/master/examples/haskell-miso.org/nix/config.nix](config.nix)

---

### Nix the language
  - Dynamically-typed (types resolved at runtime)
  - Strongly-type (explicit coercions)
  - Lazy, call-by-need evaluation
  - Pure, no side-effects
    - (modulo fixed-output derivations, but these a considered "pure").

---

### Nix the language
  - sets
    - ```{ key = "value"; }```
	- `nixpkgs` itself is just a giant set
	  - [all-packages.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix)
  - functions
    - ```nix-repl> let k = { a ? 4 }: a + 1; in if k {} == 5 then true else false```
    - `true`

---

### Nix the language
  - atoms
    - ints, bools, uri, null

---

### Nix the language
  - `inherit` is like `RecordWildCards` packing `let name = "joe"; age = 33; in p@Person {..} = person`
    - a = { inherit (pkgs) foo }, is the same as `{ foo = pkgs.foo }`

---

### Nix the language
  - `with`, like `RecordWildCards` unpacking

    - `let Person {..} = person`
    - `nix-shell -p 'haskellPackages.ghcWithPackages (p: with p; [ aeson ])'`

---

### Derivation
  - Nix jargon, used to construct `IO Package`
  - `stdenv.derivation`
  - `Derivations` are the IR that nix produces in order to calculate a build hash, and realize a build.
    - This hash is used in the output path, and referenceable in derivations as `$out`

---

### Derivation

```nix
{ pkgs ? import <nixpkgs> {} }:
  pkgs.stdenv.mkDerivation {
    name = "libpostal";
    src = ./.;
    buildInputs = with pkgs; [ curl autoreconfHook ];
    installPhase = ''
      mkdir -p $out
      ./bootstrap.sh
      ./configure --prefix=$out
      make -j4
      make install
    '';
  }
```

---


### Derivation
  - `nix-build`, forces lazy evaluation of a derivation
    - `nix-build` is `nix-instantiate` + `nix-store --realize`
	- Can install to profile with `nix-env -i ./result`

---

### setup.sh aka "the script"
  - All nix derivations use this script
  - The "reactor" of nix
    - [the script](https://github.com/NixOS/nixpkgs/blob/90959f89b88d368605f9fe93c1ca5e2c6dd23c4b/pkgs/stdenv/generic/setup.sh)

---

### The script
  - Builds operate in phases `configure`, `build`, `install`
    - `pre`/`post` are available for each
	- New phases can be defined for building language infrastructure
	  - `Haskell` + `Python` infrastructure

---

### Garbage Collection
  - `nix-env -i` puts packages into your profile
     - To view packages in your profile `nix-env -qA '*'`
  - Packages in a profile are never deleted from the system
    - This is so nix can allow you to rollback

---

### Garbage Collection
  - A user profile is a sequence of packages called a generation.
  - Unused packages (packages not belonging to any generation) should be removed when disk space is finite
  - To see generations
    - `nix-env --list-generations`
  - To rollback
    - `nix-env --rollback`

---

### Nyan example!
  - Go do the `nyan` example

---

### In practice
  - `nix-shell`
    - Incremental development
  - `nix-build`
    - For cutting releases locally
  - `nix-env`
    - For installing tools into your profile

---

### Haskell example
  - `cabal2nix`
    - Generates nix expressions from cabal files
	- Gets evaluated by the the nix haskell packages infrastructure
  - `haskell.lib`
    - Convenient overrides for dealing with haskell packages
	  - show jailbreaking w/ `nyan`
    - [haskell-lib](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/lib.nix)

---

### Haskell infrastructure
  - Don't need `stack` or `cabal`
    - Can just use `runghc Setup.hs build`, since `ghc-pkg` list is all that is needed
  - Generic builder for `nix`
    - All haskell packages get evaluated with this infrastructure
      - [generic-builder.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/generic-builder.nix)

---

### Haskell infrastructure
  - All haskell packages in `nixpkgs` are generated from a stack snapshot.
    - Loosely follows stack, LTS updates usually committed directly to nixpkgs master
	  - But don't hit nixpkgs-unstable until later
      - [hackage2nix.yaml](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/haskell-modules/configuration-hackage2nix.yaml)
  - Result of all calling `cabal2nix` on `configuration-hackage2nix.yaml`
    - [hackage-packages.nix](https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/development/haskell-modules/hackage-packages.nix)

---

### Data science tools
  - nltk
  - gdal
  - conda
  - numpy
  - scipy

---

### Nix and Docker
  - Docker daemon can be enabled on nixos as NixOS module
    - `virtaulisation.docker.enable = true;`
  - Can use Docker images with a NixOS base.
    - [Dockerfile](https://github.com/GaloisInc/regex-fsm/blob/master/Dockerfile)

---

### Nix and Docker
  - Docker image registry also available (if not using dockerhub).
    - `services.dockerRegistry.enable = true;`
	- (https://github.com/NixOS/nixpkgs/blob/release-18.03/nixos/modules/services/misc/docker-registry.nix)[Docker Registery]
  - `Kubernetes` addons
    - `kubelet`, `kubeconfig`, etc.
    - (https://github.com/NixOS/nixpkgs/blob/release-18.03/nixos/modules/services/cluster/kubernetes/default.nix)[Kubernetes]

---

### Follow-up
  - `nixpkgs` user guide
    - [nixpkgs](https://github.com/NixOS/nixpkgs)
  - Nix manual
    - [nix-manual](https://nixos.org/nixos/manual/)
  - NixOS guide
    - [nixos-guide](https://nixos.org/nixos/manual/)
  - Haskell + Nix
    - [haskell-nix](https://github.com/Gabriel439/haskell-nix)
