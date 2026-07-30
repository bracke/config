with Config.Parsers.Dotenv;
with Config.Parsers.Ini;
with Config.Parsers.Json;
with Config.Parsers.Toml;

package body Config.Formats is

   procedure Parse
     (Fmt    : Format;
      Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Config.Parsers.Parse_Result) is
   begin
      case Fmt is
         when Dotenv => Config.Parsers.Dotenv.Parse (Text, Into, Id, Result);
         when Ini    => Config.Parsers.Ini.Parse (Text, Into, Id, Result);
         when Json   => Config.Parsers.Json.Parse (Text, Into, Id, Result);
         when Toml   => Config.Parsers.Toml.Parse (Text, Into, Id, Result);
      end case;
   end Parse;

end Config.Formats;
