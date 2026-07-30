--  Config_Runtime.File — a source that reads a config file and parses it into
--  the store. The format is detected from the path's extension (.env/.ini/.json/
--  .toml/.cfg/.conf) unless Detect is False, in which case Format is used. A
--  missing file is not an error when Optional (the default). Path is an access
--  discriminant and must outlive the source.
with Config.Sources;
with Config.Store;
with Config.Formats;
package Config_Runtime.File is

   type Source (Path : not null access constant String) is
     limited new Config.Sources.Source with record
      Format   : Config.Formats.Format := Config.Formats.Toml;
      Detect   : Boolean := True;
      Optional : Boolean := True;
   end record;

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean);

end Config_Runtime.File;
