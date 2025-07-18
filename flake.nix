{
  description = "Base64 encode and decode functions in pure Nix. ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      libbase64 = import ./base64 { inherit (nixpkgs) lib; };
    in
    {
      overlays.default = final: prev: {
        lib = prev.lib // libbase64;
      };
      lib = libbase64;
    };
}
