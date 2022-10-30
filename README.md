# Bitcoin Block Verifier

This is a proof-of-concept Bitcoin block verifier that uses the (modified) Bitcoin Core source code to check the proof of work and header validity (and to some extent transaction validity) of a Bitcoin block.

The verifier is compiled to Wasm to be further transpiled to a STARK circuit.

### WARNING: This is not safe to rely on for transaction verification. It is currently used to test and drive development of the Starkify transpiler.

## Manifest

The verifier consists of:

- bitcoin-verify.cpp: the code to deserialize and verify a Bitcoin block
- bitcoin.patch: a patch for the Bitcoin Core source code (version 23.0)
- default.nix: Nix build instructions to produce the Wasm with a cross-compiler toolchain

## Building

The Wasm binary can be built with Nix:

```bash
nix-build
```

The build has 3 steps:

1. Download and extract the Bitcoin Core source code.
2. Apply our Bitcoin “Wasm patch”.
3. Build the verifier with clang.

We do not use the configure or build scripts from Bitcoin Core.

## Patching Methodology

The Wasm compiler used (Clang 12) does not support the following features used by Bitcoin Core:

- Exceptions
- Filesystem access
- Multi-threading (atomic, mutex, etc.)
- Networking

We must remove or modify any code using the above. Additionally, the particular cross-compiling toolchain that is available currently in Nixpkgs does not provide a compatible Boost library (possibly because the Boost libraries are not compatible with Wasm), so we also patch out any Boost dependencies.

## Further Work

If this is to be used seriously for Bitcoin block verification, it needs to be integrated into a recursive STARK that is fed all Bitcoin blocks appearing on the Bitcoin Mainnet and add logic that prevents rewinding proof-of-work difficulty. It would also need to be adapted to “fork” a parallel proof of X confirmations when verifying a transaction of Y value, to prevent forging transactions worth more than the work required to generate such blocks.

In order to make the verifier easier to audit, the size of the Bitcoin Core source patch should be reduced, and the verifier code and patch should be reviewed.
