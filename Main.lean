/-
Copyright (c) 2025 Yuri de Wit. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuri de Wit
-/
import Shimmer

import Lean.Language.Lean

open Lean System Shimmer

def emitCShim (module : Name) (outFile? : Option FilePath) : IO PUnit := do
  let env ← Lean.importModules #[{module}] Options.empty
  let shim := getModuleShim env module
  if let some outFile := outFile? then
    IO.FS.writeFile outFile (toString shim)
  else
    IO.print shim

def main (args : List String) : IO UInt32 := do
  if let module :: args := args then
    try
      Lean.initSearchPath (← Lean.findSysroot)
      emitCShim module.toName args.head?
      return 0
    catch e =>
      IO.eprintln s!"error: {toString e}"
      return 1
  else
    let appName := (← IO.appPath).fileName.getD "alloy"
    IO.eprintln s!"Usage: {appName} lean-file [out-file]"
    return 1
