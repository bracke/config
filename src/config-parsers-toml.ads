--  Config.Parsers.Toml — parse a TOML blob into a store. Supported: comments,
--  `[table]` headers with dotted names, dotted keys, basic and literal strings
--  (single-line and multiline), integers (decimal/hex/octal/binary with `_`
--  separators and sign, normalised to decimal), floats (with `_`), booleans,
--  datetimes (kept as text), arrays of scalars (value lists), and inline tables
--  (flattened to dotted keys). Array-of-tables (`[[t]]`) and arrays containing
--  arrays or tables are reported as unsupported. Every value maps to the same
--  store model (CFG-INV-008); malformed or unsupported input is reported with a
--  line number, never raised (CFG-INV-007).
with Config.Store;
package Config.Parsers.Toml
  with Preelaborate
is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result);

end Config.Parsers.Toml;
