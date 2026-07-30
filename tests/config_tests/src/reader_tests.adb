with Interfaces; use type Interfaces.Integer_64;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Values;
with Config.Store;
with Config.Sources.Memory;
with Config.Reader;

package body Reader_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   use Config.Reader;

   function Contains (Haystack, Needle : String) return Boolean is
   begin
      if Needle'Length = 0 or else Haystack'Length < Needle'Length then
         return Needle'Length = 0;
      end if;
      for I in Haystack'First .. Haystack'Last - Needle'Length + 1 loop
         if Haystack (I .. I + Needle'Length - 1) = Needle then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   procedure Test_Layered_Precedence (Item : in out Fixture) is
      pragma Unreferenced (Item);
      St   : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 512);
      Defs : Config.Sources.Memory.Source (4, 8, 256);
      Env  : Config.Sources.Memory.Source (4, 8, 256);
      Ok   : Boolean;
   begin
      --  defaults (id 1): host + port
      Defs.Set ("server.host", "localhost", Ok => Ok);
      Defs.Set ("server.port", "8080", Config.Values.Integer_Value, Ok => Ok);
      --  environment (id 2, higher precedence): overrides port only
      Env.Set ("server.port", "9090", Config.Values.Integer_Value, Ok => Ok);

      Defs.Load (St, Id => 1, Ok => Ok);
      Assert (Ok, "defaults loaded");
      Env.Load (St, Id => 2, Ok => Ok);
      Assert (Ok, "env loaded");

      Assert (Get_String (St, "server.host") = "localhost", "host from defaults");
      Assert (Config.Store.Provenance (St, "server.host") = 1, "host prov 1");
      Assert (Get_Integer (St, "server.port", 0) = 9090, "port overridden");
      Assert (Config.Store.Provenance (St, "server.port") = 2, "port prov 2");
   end Test_Layered_Precedence;

   procedure Test_Typed_Access (Item : in out Fixture) is
      pragma Unreferenced (Item);
      St : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 512);
      Ok : Boolean;
   begin
      Config.Store.Set (St, "n", "42", Config.Values.Integer_Value, Ok => Ok);
      Config.Store.Set (St, "f", "3.5", Config.Values.Float_Value, Ok => Ok);
      Config.Store.Set (St, "b", "yes", Config.Values.Boolean_Value, Ok => Ok);
      Config.Store.Set (St, "s", "hi", Ok => Ok);

      Assert (Get_Integer (St, "n", 0) = 42, "integer");
      Assert (Get_Float (St, "f", 0.0) > 3.4 and then Get_Float (St, "f", 0.0)
              < 3.6, "float");
      Assert (Get_Boolean (St, "b", False), "boolean yes -> true");
      Assert (Get_String (St, "s") = "hi", "string");
      --  defaults for absent keys
      Assert (Get_Integer (St, "absent", 7) = 7, "integer default");
      Assert (Get_Boolean (St, "absent", True), "boolean default");
   end Test_Typed_Access;

   procedure Test_Missing_And_Invalid (Item : in out Fixture) is
      pragma Unreferenced (Item);
      St  : Config.Store.Store (Capacity => 4, Values_Capacity => 8, Pool => 256);
      Ok  : Boolean;
      IV  : Interfaces.Integer_64;
      Sta : Lookup_Status;
   begin
      Config.Store.Set (St, "notnum", "abc", Ok => Ok);
      Get_Integer (St, "notnum", IV, Sta);
      Assert (Sta = Invalid, "non-numeric reported Invalid, not raised");
      Get_Integer (St, "gone", IV, Sta);
      Assert (Sta = Missing, "absent reported Missing");
      declare
         BV : Boolean; BSt : Lookup_Status;
      begin
         Config.Store.Set (St, "notbool", "maybe", Ok => Ok);
         Get_Boolean (St, "notbool", BV, BSt);
         Assert (BSt = Invalid, "non-boolean reported Invalid");
      end;
   end Test_Missing_And_Invalid;

   procedure Test_Redacted_Dump (Item : in out Fixture) is
      pragma Unreferenced (Item);
      St : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 512);
      Ok : Boolean;
   begin
      Config.Store.Set (St, "user", "alice", Ok => Ok);
      Config.Store.Set (St, "password", "s3cr3t", Secret => True, Ok => Ok);
      Config.Store.Append (St, "hosts", "a", Ok => Ok);
      Config.Store.Append (St, "hosts", "b", Ok => Ok);
      declare
         D : constant String := Dump (St);
      begin
         Assert (Contains (D, "user = alice"), "user shown: " & D);
         Assert (Contains (D, "password = [redacted]"), "password redacted: " & D);
         Assert (not Contains (D, "s3cr3t"), "secret value absent: " & D);
         Assert (Contains (D, "hosts = [a, b]"), "array rendered: " & D);
      end;
   end Test_Redacted_Dump;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test
        (Caller.Create ("Sources: layered precedence",
                        Test_Layered_Precedence'Access));
      Suite.Add_Test
        (Caller.Create ("Reader: typed access", Test_Typed_Access'Access));
      Suite.Add_Test
        (Caller.Create ("Reader: missing and invalid",
                        Test_Missing_And_Invalid'Access));
      Suite.Add_Test
        (Caller.Create ("Reader: redacted dump", Test_Redacted_Dump'Access));
   end Add_Tests;

end Reader_Tests;
