with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Reader;
with Config_Secrets;
with Secrets.Values;

package body Bridge_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);

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

   --  A store with one secret value and one ordinary value.
   procedure Populate (S : in out Config.Store.Store) is
      Ok : Boolean;
   begin
      Config.Store.Clear (S);
      Config.Store.Set (S, "db.password", "hunter2", Secret => True, Ok => Ok);
      Config.Store.Set (S, "app.name", "demo", Ok => Ok);
   end Populate;

   procedure Test_Get_Secret (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S   : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
      Sec : Secrets.Values.Secret;
   begin
      Populate (S);
      Sec := Config_Secrets.Get_Secret (S, "db.password");
      Assert (Secrets.Values.Reveal_String (Sec) = "hunter2",
              "secret value round-trips into a Secret");
      --  The protected handle redacts itself, never showing the value.
      Assert (not Contains (Secrets.Values.Image (Sec), "hunter2"),
              "Secret Image does not leak the value");
   end Test_Get_Secret;

   procedure Test_Is_Secret (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
   begin
      Populate (S);
      Assert (Config_Secrets.Is_Secret (S, "db.password"), "flagged secret");
      Assert (not Config_Secrets.Is_Secret (S, "app.name"), "not secret");
      Assert (not Config_Secrets.Is_Secret (S, "missing"), "absent not secret");
   end Test_Is_Secret;

   procedure Test_Absent (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S   : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
      Sec : Secrets.Values.Secret;
   begin
      Populate (S);
      Sec := Config_Secrets.Get_Secret (S, "missing");
      Assert (Secrets.Values.Is_Empty (Sec), "absent key yields empty Secret");
   end Test_Absent;

   procedure Test_Dump_Redacts (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
   begin
      Populate (S);
      declare
         D : constant String := Config.Reader.Dump (S);
      begin
         Assert (not Contains (D, "hunter2"), "dump does not show the secret");
         Assert (Contains (D, Config.Reader.Redacted), "dump redacts the secret");
         Assert (Contains (D, "demo"), "dump still shows non-secret values");
      end;
   end Test_Dump_Redacts;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test (Caller.Create ("Bridge: get secret", Test_Get_Secret'Access));
      Suite.Add_Test (Caller.Create ("Bridge: is secret", Test_Is_Secret'Access));
      Suite.Add_Test (Caller.Create ("Bridge: absent key", Test_Absent'Access));
      Suite.Add_Test (Caller.Create ("Bridge: dump redacts", Test_Dump_Redacts'Access));
   end Add_Tests;

end Bridge_Tests;
