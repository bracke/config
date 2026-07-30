--  Quickstart — layered configuration end to end: TOML defaults, an explicit
--  secret, and an environment override, read back with typed access and printed
--  as a redacted dump. Exercised by the release checks (which also builds the
--  config_runtime adapter used here).
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;

with Config;
with Config.Store;
with Config.Reader;
with Config.Formats;
with Config.Parsers;

with Config_Runtime.Environment;

procedure Quickstart is
   LF : constant Character := ASCII.LF;

   Defaults : constant String :=
     "[server]" & LF
     & "host = ""localhost""" & LF
     & "port = 8080" & LF;

   St  : Config.Store.Store (Capacity => 32, Values_Capacity => 64, Pool => 4096);
   PR  : Config.Parsers.Parse_Result;
   Ok  : Boolean;

   Prefix : aliased constant String := "DEMO_";
   Env    : Config_Runtime.Environment.Source (Prefix'Access);
begin
   Put_Line ("config " & Config.Library_Version & " quickstart");

   --  Layer 1: TOML defaults.
   Config.Formats.Parse (Config.Formats.Toml, Defaults, St, Id => 1, Result => PR);

   --  A secret value (parsers don't mark secrets; the app does).
   Config.Store.Set (St, "db.password", "s3cr3t", From => 1, Secret => True,
                     Ok => Ok);

   --  Layer 2: environment overrides (e.g. DEMO_SERVER_PORT overrides the port).
   Env.Load (St, Id => 2, Ok => Ok);

   Put_Line ("server.host = " & Config.Reader.Get_String (St, "server.host"));
   Put_Line ("server.port ="
             & Interfaces.Integer_64'Image
                 (Config.Reader.Get_Integer (St, "server.port", 0)));

   Put_Line ("--- effective config (secrets redacted) ---");
   Put (Config.Reader.Dump (St));
end Quickstart;
