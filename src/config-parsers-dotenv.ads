--  Config.Parsers.Dotenv — parse a dotenv blob (KEY=VALUE lines) into a store.
--  Blank lines and full-line '#' comments are ignored; an optional leading
--  "export " is stripped. Values may be bare, single-quoted (literal), or
--  double-quoted (with escapes). Keys are taken literally and must be valid
--  config keys (dots and underscores are allowed). The first malformed line, or
--  a store overflow, is reported in the result.
with Config.Store;
package Config.Parsers.Dotenv
  with Preelaborate
is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result);

end Config.Parsers.Dotenv;
