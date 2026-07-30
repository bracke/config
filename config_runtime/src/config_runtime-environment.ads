--  Config_Runtime.Environment — a source that reads process environment
--  variables. Each variable whose name starts with Prefix is mapped to a dotted
--  key (see Config.Env: strip prefix, lowercase, '_' -> '.') and set in the
--  store. The prefix is an access discriminant, so it must outlive the source.
with Config.Sources;
with Config.Store;
package Config_Runtime.Environment is

   type Source (Prefix : not null access constant String) is
     limited new Config.Sources.Source with null record;

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean);

end Config_Runtime.Environment;
