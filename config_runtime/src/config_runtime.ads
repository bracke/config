--  Config_Runtime — the I/O adapters for the headless `config` core: sources
--  that read real environment variables and files. These do the environment and
--  file access the core forbids. Both implement Config.Sources.Source and report
--  failure via Ok rather than raising.
package Config_Runtime
  with Pure
is

   --  Largest config file the file source will read; larger files fail closed.
   Max_File_Bytes : constant := 2 ** 20;   --  1 MiB

end Config_Runtime;
