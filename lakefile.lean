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

module_facet shim.c mod : FilePath := do
  let exeJob ← shimmer.fetch
  let modJob ← mod.olean.fetch
  let cFile := mod.irPath "shim.c"
  exeJob.bindM fun exeFile => do
  modJob.mapM fun _ => do
    buildFileUnlessUpToDate' cFile do
      proc {
        cmd := exeFile.toString
        args := #[mod.name.toString, cFile.toString]
        env := #[("LEAN_PATH", (← getLeanPath).toString)]
      }
    return cFile

@[inline] def buildShimO (mod : Module) (shouldExport : Bool) : FetchM (Job FilePath) := do
  let oFile := mod.irPath s!"shim.c.o.{if shouldExport then "export" else "noexport"}"
  let cJob ← fetch <| mod.facet `shim.c
  let weakArgs := #["-I", (← getLeanIncludeDir).toString] ++ mod.weakLeancArgs
  let cc := (← IO.getEnv "CC").getD "cc"
  let leancArgs := if shouldExport then mod.leancArgs.push "-DLEAN_EXPORTING" else mod.leancArgs
  buildO oFile cJob weakArgs leancArgs cc

module_facet shim.c.o.export mod : FilePath := buildShimO mod true
module_facet shim.c.o.noexport mod : FilePath :=  buildShimO mod false
