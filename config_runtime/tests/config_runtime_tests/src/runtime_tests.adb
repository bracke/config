with Ada.Directories;
with Ada.Environment_Variables;
with Ada.Text_IO;

with Interfaces; use type Interfaces.Integer_64;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Reader;

with Config_Runtime.Environment;
with Config_Runtime.File;

package body Runtime_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);

   procedure Test_Environment (Item : in out Fixture) is
      pragma Unreferenced (Item);
      Prefix : aliased constant String := "CFGTEST_";
      Env    : Config_Runtime.Environment.Source (Prefix'Access);
      St     : Config.Store.Store (32, 64, 4096);
      Ok     : Boolean;
   begin
      Ada.Environment_Variables.Set ("CFGTEST_SERVER_PORT", "8080");
      Ada.Environment_Variables.Set ("CFGTEST_SERVER_HOST", "localhost");
      Env.Load (St, Id => 3, Ok => Ok);
      Assert (Ok, "env loaded");
      Assert (Config.Reader.Get_Integer (St, "server.port", 0) = 8080,
              "SERVER_PORT -> server.port = 8080");
      Assert (Config.Reader.Get_String (St, "server.host") = "localhost",
              "SERVER_HOST -> server.host");
      Assert (Config.Store.Provenance (St, "server.port") = 3, "provenance");
      Ada.Environment_Variables.Clear ("CFGTEST_SERVER_PORT");
      Ada.Environment_Variables.Clear ("CFGTEST_SERVER_HOST");
   end Test_Environment;

   procedure Test_File_Roundtrip (Item : in out Fixture) is
      pragma Unreferenced (Item);
      Path : aliased constant String := "cr_test.toml";
      Src  : Config_Runtime.File.Source (Path'Access);
      St   : Config.Store.Store (16, 32, 2048);
      Ok   : Boolean;
      F    : Ada.Text_IO.File_Type;
   begin
      if Ada.Directories.Exists (Path) then
         Ada.Directories.Delete_File (Path);
      end if;
      Ada.Text_IO.Create (F, Ada.Text_IO.Out_File, Path);
      Ada.Text_IO.Put_Line (F, "[server]");
      Ada.Text_IO.Put_Line (F, "host = ""localhost""");
      Ada.Text_IO.Put_Line (F, "port = 8080");
      Ada.Text_IO.Close (F);

      Src.Load (St, Id => 2, Ok => Ok);   --  format auto-detected from .toml
      Assert (Ok, "file loaded");
      Assert (Config.Reader.Get_String (St, "server.host") = "localhost",
              "host from file");
      Assert (Config.Reader.Get_Integer (St, "server.port", 0) = 8080,
              "port from file");

      Ada.Directories.Delete_File (Path);
   end Test_File_Roundtrip;

   procedure Test_File_Missing (Item : in out Fixture) is
      pragma Unreferenced (Item);
      Path : aliased constant String := "cr_absent.toml";
      St   : Config.Store.Store (4, 8, 256);
      Ok   : Boolean;
   begin
      declare
         Opt : Config_Runtime.File.Source (Path'Access);
      begin
         Opt.Load (St, 1, Ok);
         Assert (Ok, "missing optional file is not an error");
         Assert (Config.Store.Count (St) = 0, "nothing loaded");
      end;
      declare
         Req : Config_Runtime.File.Source (Path'Access);
      begin
         Req.Optional := False;
         Req.Load (St, 1, Ok);
         Assert (not Ok, "missing required file is an error");
      end;
   end Test_File_Missing;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      S : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      S.Add_Test (Caller.Create ("Runtime: environment", Test_Environment'Access));
      S.Add_Test
        (Caller.Create ("Runtime: file round-trip", Test_File_Roundtrip'Access));
      S.Add_Test (Caller.Create ("Runtime: file missing", Test_File_Missing'Access));
      return S;
   end Suite;

end Runtime_Tests;
