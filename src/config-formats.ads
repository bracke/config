--  Config.Formats — the unified parser dispatch. Given a format and a text blob,
--  parse it into a store through the matching parser. A file source picks the
--  format from the file's extension; an application can call this directly.
with Config.Store;
with Config.Parsers;
package Config.Formats is

   type Format is (Dotenv, Ini, Json, Toml);

   --  Parse Text in the given format into Into, tagged with Id.
   procedure Parse
     (Fmt    : Format;
      Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Config.Parsers.Parse_Result);

end Config.Formats;
