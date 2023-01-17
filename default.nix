{ pkgs ? import (builtins.fetchTarball {
    name = "nixos-22.11";
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/22.05.tar.gz";
    sha256 = "sha256:0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
  }) {}
}:

let
  llvmPackages = pkgs.pkgsCross.wasi32.llvmPackages;
  bitcoin-version = "23.0";
  bitcoin-src = builtins.fetchTarball rec {
    url = "https://bitcoincore.org/bin/bitcoin-core-${bitcoin-version}/bitcoin-${bitcoin-version}.tar.gz";
    sha256 = "sha256:0fgk16avwylwafx18h609wyww2g0qpmfs71k0mbm63dly7jrwjas";
  };
  bitcoin-wasm = pkgs.applyPatches {
    name = "bitcoin-wasm";
    src = bitcoin-src;
    patches = [
      ./bitcoin.patch
    ];
  };
  required-cpp-files = [
    "arith_uint256"
    "chainparams"
    "chainparamsbase"
    # "consensus/merkle"
    # "consensus/tx_check"
    # "consensus/tx_verify"
    "crypto/sha256"
    "pow"
    "primitives/block"
    # "primitives/transaction"
    # "script/script"
    # "support/cleanse"
    "uint256"
    # "util/moneystr"
    "util/strencodings"
    "validation"
  ];
in llvmPackages.stdenv.mkDerivation {
  name = "bitcoin-verify";
  src = ./.;
  nativeBuildInputs = [
    llvmPackages.libcxx
  ];
  buildPhase = ''
    head -c 80 ./block.raw > header_bytes &&
    ${pkgs.xxd}/bin/xxd -i header_bytes header.h &&
    $CXX --std=c++17 -Os -o bitcoin-verify.wasm bitcoin-verify.cpp ${builtins.concatStringsSep " " (map (f: "${bitcoin-wasm}/src/${f}.cpp") required-cpp-files)} -I${bitcoin-wasm}/src -Wl,--no-entry -Wl,--strip-all
  '';
  installPhase = ''
    mkdir $out
    cp bitcoin-verify.wasm $out/
  '';
  shellHook = ''
    alias diff-bitcoin='diff -u -r ${bitcoin-src} ../bitcoin-src | sed -e "s|${bitcoin-src}|old|" -e "s|../bitcoin-src|new|"'
  '';
}
