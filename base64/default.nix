{ lib, ... }:
let
  # Extracts the i-th slice of length `size` from a `list`.
  ithSlice =
    size: list: i:
    lib.sublist (i * size) size list;

  # Converts an integer to a list of digits in `base`.
  digitsOf =
    base: pows: i:
    map (p: lib.mod (i / p) base) pows;

  # Fold a list of digits to an int, given `base`.
  foldBase = base: builtins.foldl' (acc: d: acc * base + d) 0;

  # -- CONVERTERS --

  # Chars <-> bytes.
  charToBytes = lib.strings.charToInt;
  bytesToChar =
    i:
    let
      hex = lib.fixedWidthString 2 "0" (lib.toHexString i);
    in
    builtins.fromJSON "\"\\u00${hex}\"";

  # Chars <-> sextets.
  lookup = lib.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  charToSextet = c: if c == "=" then 0 else (lib.lists.findFirstIndex (x: x == c) 0 lookup);
  sextetToChar = builtins.elemAt lookup;

  # Ints <-> bytes.
  intToBytes = digitsOf 256 [
    (256 * 256)
    (256)
    (1)
  ];
  bytesToInt = foldBase 256;

  # Ints <-> sextets.
  intToSextets = digitsOf 64 [
    (64 * 64 * 64)
    (64 * 64)
    (64)
    (1)
  ];
  sextetsToInt = foldBase 64;
in
{
  # toBase64 :: String -> String
  toBase64 =
    str:
    let
      bytes = map charToBytes (lib.stringToCharacters str);
      numTriplets = (builtins.stringLength str) / 3;
      tripletAt = ithSlice 3 bytes;

      convertTriplet = slice: lib.concatMapStrings sextetToChar (intToSextets (bytesToInt slice));
      convertLastTriplet =
        slice:
        let
          len = builtins.length slice;
          slice' = slice ++ lib.replicate (3 - len) 0;
          encoded = lib.concatMapStrings sextetToChar (intToSextets (bytesToInt slice'));
        in
        lib.optionalString (len < 3) (
          builtins.substring 0 (len + 1) encoded + lib.strings.replicate (3 - len) "="
        );

      # Unpadded heads and potentially-padded tail.
      heads = builtins.genList (i: convertTriplet (tripletAt i)) numTriplets;
      tail = convertLastTriplet (tripletAt numTriplets);
    in
    lib.concatStrings (heads ++ [ tail ]);

  # fromBase64 :: String -> String
  fromBase64 =
    str:
    let
      sextets = map charToSextet (lib.stringToCharacters str);
      numQuartets = (builtins.stringLength str) / 4;
      quartetAt = ithSlice 4 sextets;

      convertQuartet = slice: lib.concatMapStrings bytesToChar (intToBytes (sextetsToInt slice));
      convertLastQuartet =
        slice:
        let
          pad = builtins.length (lib.filter (s: s == "=") (lib.stringToCharacters str));
          decoded = intToBytes (sextetsToInt slice);
        in
        lib.concatMapStrings bytesToChar (lib.sublist 0 (3 - pad) decoded);

      # Unpadded heads and potentially-padded tail.
      heads = builtins.genList (i: convertQuartet (quartetAt i)) (numQuartets - 1);
      tail = convertLastQuartet (quartetAt (numQuartets - 1));
    in
    lib.concatStrings (heads ++ [ tail ]);
}
