--  Config.Parsers.Ini — parse an INI blob into a store. `[section]` headers set
--  the current section; a `key = value` line becomes the dotted key
--  `section.key` (or just `key` under the global section). Blank lines and
--  full-line '#' or ';' comments are ignored. Values may be bare, single-quoted,
--  or double-quoted. Sections and keys must form valid config keys. The first
--  malformed line, or a store overflow, is reported.
with Config.Store;
package Config.Parsers.Ini
  with Preelaborate
is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result);

end Config.Parsers.Ini;
