--  Config.Parsers.Json — parse a JSON object into a store, using representation's
--  JSON decoder (CFG-INV-009). Nested objects flatten to dotted keys; arrays of
--  scalars become value lists; JSON null members are omitted. The root must be
--  an object. A decode error, an unsupported structure (an array containing an
--  object or array), an invalid key, or a store overflow is reported rather than
--  raised (CFG-INV-007). Number values are typed integer or float by their form.
with Config.Store;
package Config.Parsers.Json is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result);

end Config.Parsers.Json;
