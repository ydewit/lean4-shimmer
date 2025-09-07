/-
Copyright (c) 2025 Yuri de Wit. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuri de Wit
-/
import Lake
open Lake DSL System

package shimmer

-- # Build

lean_lib Shimmer

@[default_target]
lean_exe shimmer where
  root := `Main
  supportInterpreter := true


-- # Module Facets

/--
This facet produces a `shim.c` file for each Lean module.

So if there is a source module `Simple.lean`, this facet will
generate a `Simple.shim.c` in `.lake/build/ir/` based on the
module exports.

However, if there is a Simple.shim.c alongside `Simple.lean`,
this facet will *not* generate a new file `.shim.c` file, but
will instead reuse the existing one.

Manually placing a `shim.c` file alongside a Lean source file
is useful for testing or when you want to provide your own
shim implementation.
-/
module_facet shim.c mod : FilePath := do
  let exeJob ← shimmer.fetch
  let modJob ← mod.olean.fetch
  let cFile := mod.srcPath "shim.c"
  if (← cFile.pathExists) then
    buildFileUnlessUpToDate' cFile do
      logInfo s!"Using existing shim.c file {cFile}"
    inputTextFile cFile
  else
    exeJob.bindM fun exeFile => do
      modJob.mapM fun _ => do
        let cFile := mod.irPath "shim.c"
        buildFileUnlessUpToDate' cFile do
          logInfo s!"Generating shim.c file {cFile}"
          proc {
            cmd := exeFile.toString
            args := #[mod.name.toString, cFile.toString]
            env := #[("LEAN_PATH", (← getLeanPath).toString)]
          }
        return cFile

/--
This helper funtion is used to build `shim.c.o` files from
`shim.c` files. Note that this function can save the file as
`shim.c.o.export` or `shim.c.o.noexport` depending on the
`shouldExport` flag.
-/
@[inline] def buildShimO (mod : Module) (shouldExport : Bool) : FetchM (Job FilePath) := do
  let oFile := mod.irPath s!"shim.c.o.{if shouldExport then "export" else "noexport"}"
  let cJob ← do
    let cFile := mod.srcPath "shim.c"
    if (← cFile.pathExists) then
      IO.println s!"Using existing shim.c file at {cFile}"
      inputTextFile cFile
    else
      fetch (mod.facet `shim.c)

  let mut weakArgs := #["-I", (← getLeanIncludeDir).toString]
  weakArgs := weakArgs ++ #["-I", mod.pkg.srcDir.toString]
  weakArgs := weakArgs ++ mod.weakLeancArgs

  let leancArgs := if shouldExport then mod.leancArgs.push "-DLEAN_EXPORTING" else mod.leancArgs
  buildO oFile cJob weakArgs leancArgs

/--
These two `module_facet`s enables other Lean projects to compile the `shim.c` files.

To use them, you can add the following lines to your `lakefile.lean`:
```
module_data oShimExportFacet : FilePath
module_data oShimNoExportFacet : FilePath
```
-/
module_facet oShimExportFacet mod : FilePath := buildShimO mod true
module_facet oShimNoExportFacet mod : FilePath := buildShimO mod false
