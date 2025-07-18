{
  description = "Base64 encode and decode functions in pure Nix. ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    {
      lib = { };
    };
}
