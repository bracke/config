--  Config.Reader — typed access over a store. Each getter parses a value to its
--  type with required-vs-default semantics; a missing key or a value that will
--  not parse is reported (Lookup_Status) or falls back to a default — never
--  raised (CFG-INV-004, CFG-INV-005). Integer/float parsing uses the language's
--  validated 'Value with internal error containment; booleans use the config
--  boolean vocabulary. Dump renders the effective config with secrets redacted
--  (CFG-INV-006).
with Interfaces;

with Config.Store;
package Config.Reader is

   subtype Store is Config.Store.Store;

   type Lookup_Status is
     (Found,     --  present and parsed
      Missing,   --  key not in the store
      Invalid);  --  present but does not parse as the requested type

   Redacted : constant String := "[redacted]";

   --  String: the key's first value, or Default when absent.
   function Get_String
     (S : Store; Key : String; Default : String := "") return String;

   --  Integer (signed 64-bit).
   procedure Get_Integer
     (S : Store; Key : String;
      Result : out Interfaces.Integer_64; Status : out Lookup_Status);
   function Get_Integer
     (S : Store; Key : String; Default : Interfaces.Integer_64)
      return Interfaces.Integer_64;

   --  Float.
   procedure Get_Float
     (S : Store; Key : String;
      Result : out Long_Float; Status : out Lookup_Status);
   function Get_Float
     (S : Store; Key : String; Default : Long_Float) return Long_Float;

   --  Boolean (true/false, yes/no, on/off, 1/0).
   procedure Get_Boolean
     (S : Store; Key : String;
      Result : out Boolean; Status : out Lookup_Status);
   function Get_Boolean
     (S : Store; Key : String; Default : Boolean) return Boolean;

   --  Render the effective config as "key = value" lines (arrays as
   --  "[a, b, c]"), in insertion order, with secret keys shown as the
   --  redaction placeholder.
   function Dump (S : Store) return String;

end Config.Reader;
