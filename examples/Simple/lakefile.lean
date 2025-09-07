import Lake
open System Lake DSL


package simple where
  buildType := .debug

require shimmer from ".."/".."

module_data oShimExportFacet : FilePath
module_data oShimNoExportFacet : FilePath


@[default_target]
lean_lib Simple where
  precompileModules := true
  defaultFacets := #[LeanLib.staticFacet, LeanLib.sharedFacet]
  nativeFacets := fun shouldExport =>
    if shouldExport then
      #[Module.oExportFacet, `module.oShimExportFacet]
    else
      #[Module.oNoExportFacet, `module.oShimNoExportFacet]

@[default_target]
lean_exe simple where
  root := `Main
