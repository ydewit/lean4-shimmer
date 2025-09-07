
# lean4-shimmer

**lean4-shimmer** is a work-in-progress tool to help generate `.c` shims for functions exported from Lean 4 using `@[export ...]`. Writing these bindings and handling all the parameters by hand is tedious and error-prone—this project aims to automate that process.

## What does it do?

- Scans Lean 4 modules for exported functions.
- Automatically generates the corresponding C shims.
- Outputs the generated C code to a file or to stdout.

## Usage

Here is a sample `lakefile.lean` for a project that produces a static 
and a shared library named `MyLib` (see `.lake/build/lib/libMyLib.a` and
`.lake/build/lib/libMyLib.dylib` or `.so` or `.dll`).

```lean
import Lake
open System Lake DSL

package mypackage

require shimmer from git "https://github.com/ydewit/lean4-shimmer.git"

module_data shim.c.o.export : FilePath
module_data shim.c.o.noexport : FilePath

@[default_target]
lean_lib MyLib where
  precompileModules := true
  defaultFacets := #[LeanLib.staticFacet, LeanLib.sharedFacet]
  nativeFacets := fun shouldExport =>
    if shouldExport then
      #[Module.oExportFacet, `module.shim.c.o.export]
    else
      #[Module.oNoExportFacet, `module.shim.c.o.noexport]
```

## Status

This project is **experimental** and under active development. The API and output format may change. Contributions and feedback are welcome!

## License

Apache 2.0
