{
  description = "Base64 encode and decode functions in pure Nix. ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      base64 = import ./base64 { inherit (nixpkgs) lib; };
    in
    {
      lib = base64;
      overlays.default = final: prev: {
        lib = prev.lib // base64;
      };
    };
}
