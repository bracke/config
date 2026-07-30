--  Config.Sources.Memory — an in-memory source for programmatic defaults and
--  overrides (and a building block for tests). Entries are staged with Set /
--  Append into a private bounded store, then replayed into a target store by
--  Load, tagged with the provenance id passed to Load.
with Config.Store;
with Config.Values;
package Config.Sources.Memory
  with Preelaborate
is

   type Source
     (Capacity        : Natural;
      Values_Capacity : Natural;
      Pool            : Natural)
     is limited new Config.Sources.Source with private;

   --  Stage a scalar entry (replaces any staged value for Key).
   procedure Set
     (Self   : in out Source;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      Secret : Boolean := False;
      Ok     : out Boolean);

   --  Stage an array element (appended to Key's staged list).
   procedure Append
     (Self   : in out Source;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      Secret : Boolean := False;
      Ok     : out Boolean);

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean);

private

   type Source
     (Capacity        : Natural;
      Values_Capacity : Natural;
      Pool            : Natural)
     is limited new Config.Sources.Source with record
      Staged : Config.Store.Store (Capacity, Values_Capacity, Pool);
   end record;

end Config.Sources.Memory;
