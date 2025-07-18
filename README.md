# nix-base64

Base64 encode and decode functions in pure Nix.

## Overview

This repository provides two Nix functions.

- `lib.toBase64 :: String -> String`
- `lib.fromBase64 :: String -> String`

## Examples

If you want to use these functions interactively.
```sh
nix-repl> :lf github:3nol/nix-base64
```

If you want to include this `lib` and/or update `<nixpkgs/lib>` in your flake.
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    base64.url = "github:3nol/nix-base64";
  };

  outputs = { self, nixpkgs, base64, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (
          final: prev: { lib = prev.lib // base64.lib; }
        )
      ];
    };
  in
  {
    # You can use your updated `pkgs.lib` here.
  };
}
```

## Credits

The function for encoding to [Base64](https://en.wikipedia.org/wiki/Base64) is heavily inspired by "https://gist.github.com/manveru/74eb41d850bc146b7e78c4cb059507e2".
I extracted common functionality from their implementation and added an analogous function for decoding.
