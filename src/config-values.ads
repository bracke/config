--  Config.Values — the value-kind taxonomy for stored/accessed config values,
--  plus the config-specific boolean vocabulary. Integer, float, and datetime
--  parsing reuse `representation` at typed-access time; this package owns the
--  kinds and the boolean spelling (config accepts more than "true"/"false").
package Config.Values
  with Pure
is

   type Value_Kind is
     (String_Value,
      Integer_Value,
      Float_Value,
      Boolean_Value,
      Datetime_Value);

   --  Canonical lowercase name of a kind (stable, locale-neutral).
   --  @param K A value kind.
   --  @return e.g. "string", "integer".
   function Image (K : Value_Kind) return String is
     (case K is
         when String_Value   => "string",
         when Integer_Value  => "integer",
         when Float_Value    => "float",
         when Boolean_Value  => "boolean",
         when Datetime_Value => "datetime");

   --  Canonical boolean image.
   --  @param B A boolean.
   --  @return "true" or "false".
   function Boolean_Image (B : Boolean) return String is
     (if B then "true" else "false");

   --  Parse a boolean, case-insensitively. Accepts true/false, yes/no, on/off,
   --  and 1/0. On failure Valid is False and Result is False.
   --  @param Text  Candidate boolean text.
   --  @param Result Parsed value (False when invalid).
   --  @param Valid True when Text named a boolean.
   procedure Parse_Boolean
     (Text : String; Result : out Boolean; Valid : out Boolean);

end Config.Values;
