/-
Copyright (c) 2025 Yuri de Wit. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuri de Wit
-/
import Lean.Language.Lean
open Lean

namespace Shimmer

/-- Abbreviation for a persistent environment extension at the module level. -/
abbrev ModuleEnvExtension (σ : Type) := PersistentEnvExtension σ σ σ

/-- Register a new module environment extension. -/
def registerModuleEnvExtension {σ} [Inhabited σ] (mkInitial : IO σ)
  (name : Name := by exact decl_name%) : IO (ModuleEnvExtension σ) :=
    registerPersistentEnvExtension {
      name            := name
      mkInitial       := pure default
      addImportedFn   := fun _ _ => mkInitial
      addEntryFn      := fun s _ => s
      exportEntriesFn := fun s => #[s]
    }

/-- Structure representing a generated C shim for a Lean module. -/
structure Shim where
  cmds : Array String
  text : FileMap
  deriving Inhabited

/-- Converts a Shim to its C code string representation. -/
instance : ToString Shim where
  toString shim := shim.text.source
