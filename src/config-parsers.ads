--  Config.Parsers — parent of the format parsers. Each child parses a text blob
--  into store entries (dotted key -> value), tagged with a provenance id. All
--  parsers are single-pass and bounded, reduce to the same entry model
--  (CFG-INV-008), and report malformed input as a value with the offending line
--  rather than raising (CFG-INV-007). dotenv/INI are here; JSON and TOML land in
--  later phases.
package Config.Parsers
  with Pure
is

   type Parse_Status is
     (Parsed,      --  the whole input parsed into the store
      Malformed,   --  a syntax error (see Line)
      Overflow);   --  the store could not hold the input (see Line)

   type Parse_Result is record
      Status : Parse_Status := Parsed;
      Line   : Natural := 0;   --  1-based line of the first error (0 if none)
   end record;

end Config.Parsers;
