
# lean4-shimmer

**lean4-shimmer** is a work-in-progress tool to help generate `.c` shims for functions exported from Lean 4 using `@[export ...]`. Writing these bindings and handling all the parameters by hand is tedious and error-prone—this project aims to automate that process.

## What does it do?

- Scans Lean 4 modules for exported functions.
- Automatically generates the corresponding C shims.
- Outputs the generated C code to a file or to stdout.

## Usage

```sh
lake build
./build/bin/lean4-shimmer <LeanModule> [output.c]
```

- `<LeanModule>`: The Lean module to scan for exports (e.g., `My.Module`).
- `[output.c]`: (Optional) Output file for the generated C shim.

If no output file is specified, the shim is printed to stdout.

## Status

This project is **experimental** and under active development. The API and output format may change. Contributions and feedback are welcome!

## License

Apache 2.0
