/-
Copyright (c) 2025 Yuri de Wit. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuri de Wit
-/
import Lean.Language.Lean
import Shimmer.Extension

open Lean

/-!
  Basic utilities for extracting and managing C shims from Lean modules.
  Provides helpers to find and retrieve shims from the Lean environment.
-/

namespace Shimmer

initialize shimExt : ModuleEnvExtension Shim ← registerModuleEnvExtension (pure default)

/-- Find the extension state for a given module, if present. -/
def find? [Inhabited σ] (ext : ModuleEnvExtension σ) (env : Environment) (mod : Name) : Option σ :=
  env.getModuleIdx? mod >>= fun idx => (ext.getModuleEntries env idx)[0]?

/-- Find the extension state for a given module, if present. -/
def getModuleShim (env : Environment) (mod : Name) : Shim :=
  find? shimExt env mod |>.getD default

/-- Retrieve the C shim for a given module from the environment. -/
@[inline] def getLocalShim (env : Environment) : Shim :=
  shimExt.getState env

/--
Prints the shim generated for the specified module of the current
module if none is specified. This is useful for debugging.

For example: `#shim Shimmer.Basic`
-/
elab outTk:"#shim" mod?:(ppSpace ident)? : command => do
  match mod? with
  | none => logInfoAt outTk <| toString <| getLocalShim (← getEnv)
  | some mod => logInfoAt outTk <| toString <| getModuleShim (← getEnv) mod.getId
