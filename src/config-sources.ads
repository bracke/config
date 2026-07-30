--  Config.Sources — the source seam. Each source contributes its entries into a
--  store, tagged with a source id for provenance. Applying sources in increasing
--  precedence order (defaults, then files, then environment, then overrides)
--  gives layered configuration: a later source overrides an earlier one for the
--  same key (CFG-INV-003), and the winning source is recorded. The core defines
--  the seam and an in-memory source; real environment and file sources live in
--  `config_runtime`.
with Config.Store;
package Config.Sources
  with Preelaborate
is

   type Source is limited interface;

   --  Load this source's entries into Into, tagging each with Id. Implementations
   --  report failure via Ok (a full store, a parse error) rather than raising.
   --  @param Self The source.
   --  @param Into The store to populate.
   --  @param Id   The provenance id to tag this source's entries with.
   --  @param Ok   True when the source loaded fully.
   procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean) is abstract;

end Config.Sources;
