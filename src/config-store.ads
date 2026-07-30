--  Config.Store — the merged configuration: a bounded flat map from a dotted key
--  to an ordered list of values (one for a scalar, many for an array), each key
--  carrying its value kind, the source that set it (provenance), and a secret
--  flag. Nested TOML tables and JSON objects flatten to dotted keys; arrays
--  become value lists. Keys, values, and provenance live in one bounded arena;
--  the store holds no heap storage. Setting an existing key replaces its value
--  list (later sources override earlier ones, CFG-INV-003); Append extends a
--  key's list (used while parsing an array).
with Config.Values;
package Config.Store
  with Preelaborate
is

   --  A source identifier for provenance (0 = unset / unknown). Real ids are
   --  assigned per layered source in Config.Sources.
   subtype Source_Id is Natural;

   type Store
     (Capacity        : Natural;   --  distinct keys
      Values_Capacity : Natural;   --  total value slots across all keys
      Pool            : Natural)   --  characters for keys + values
     is limited private;

   --  Reset the store to empty.
   procedure Clear (S : in out Store);

   --  Number of distinct keys.
   function Count (S : Store) return Natural;

   --  Set Key to a single value, replacing any existing value list and updating
   --  kind / provenance / secret. Ok is False when Key is invalid, capacity /
   --  value-slots / pool are exhausted. A value longer than Value_Length is
   --  truncated.
   procedure Set
     (S      : in out Store;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      From   : Source_Id := 0;
      Secret : Boolean := False;
      Ok     : out Boolean);

   --  Append a value to Key's list (creating the key if absent). Used to build
   --  an array from consecutive elements. Kind / provenance / secret are taken
   --  from the first element and left unchanged on later appends.
   procedure Append
     (S      : in out Store;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      From   : Source_Id := 0;
      Secret : Boolean := False;
      Ok     : out Boolean);

   --  Read view (by key).
   function Has (S : Store; Key : String) return Boolean;
   function Value_Count (S : Store; Key : String) return Natural;   --  0 if absent
   function Value (S : Store; Key : String; Index : Positive := 1) return String
     with Pre => Index <= Value_Count (S, Key);
   function Kind (S : Store; Key : String) return Config.Values.Value_Kind
     with Pre => Has (S, Key);
   function Provenance (S : Store; Key : String) return Source_Id
     with Pre => Has (S, Key);
   function Is_Secret (S : Store; Key : String) return Boolean
     with Pre => Has (S, Key);

   --  Read view (by position, for dumps/iteration; keys are in insertion order).
   function Key_At (S : Store; Index : Positive) return String
     with Pre => Index <= Count (S);

private

   type Value_Slot is record
      Start : Positive := 1;
      Len   : Natural  := 0;
   end record;
   type Value_Slot_Array is array (Positive range <>) of Value_Slot;

   type Config_Entry is record
      Key_Start  : Positive := 1;
      Key_Len    : Natural  := 0;
      Val_First  : Positive := 1;   --  index into Slots of first value
      Val_Count  : Natural  := 0;
      Kind       : Config.Values.Value_Kind := Config.Values.String_Value;
      Provenance : Source_Id := 0;
      Secret     : Boolean := False;
   end record;
   type Entry_Array is array (Positive range <>) of Config_Entry;

   type Store
     (Capacity        : Natural;
      Values_Capacity : Natural;
      Pool            : Natural) is limited record
      Entries   : Entry_Array (1 .. Capacity);
      Slots     : Value_Slot_Array (1 .. Values_Capacity);
      Chars     : String (1 .. Pool);
      N         : Natural := 0;   --  entries used
      Slot_Top  : Natural := 0;   --  value slots used
      Pool_Top  : Natural := 0;   --  chars used
   end record;

end Config.Store;
