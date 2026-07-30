with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Ada.Directories;
with Ada.Environment_Variables;

with Config.Store;
with Config.Reader;
with Config_Secrets;
with Secrets;
with Secrets.Values;
with Secrets.Vault;
with Secrets.Store; use type Secrets.Store.Status;
with Secrets.Kdf;
with Secrets_File;

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

   Vault_Path : constant String := "config_secrets_test.vault";
   Fast : constant Secrets.Kdf.Params :=
     (Iterations => 1, Memory_KiB => 32, Lanes => 1);

   --  Write a passphrase vault file holding one secret, and point a config store
   --  at it (with a different value for the same key, plus a config-only key).
   procedure Make_Vault_And_Config
     (S : in out Config.Store.Store; Passphrase : String)
   is
      V  : Secrets.Vault.Vault (Capacity => 8);
      R  : Secrets.Store.Status;
      Ok : Boolean;
   begin
      if Ada.Directories.Exists (Vault_Path) then
         Ada.Directories.Delete_File (Vault_Path);
      end if;
      V.Put ("db.password", Secrets.Values.From_String ("vault-secret"), R);
      Secrets_File.Save_With_Passphrase
        (V, Vault_Path, Secrets.Values.From_String (Passphrase), R, Fast);

      Config.Store.Clear (S);
      Config.Store.Set (S, "secrets.vault_file", Vault_Path, Ok => Ok);
      --  A config-only fallback value and a shadowed one.
      Config.Store.Set (S, "db.password", "config-value", Secret => True, Ok => Ok);
      Config.Store.Set (S, "smtp.host", "mail.example.com", Ok => Ok);
   end Make_Vault_And_Config;

   procedure Test_Vault_Backed (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
      V : Secrets.Vault.Vault (Capacity => 16);
      R : Secrets.Store.Status;
   begin
      Make_Vault_And_Config (S, "hunter2");
      Ada.Environment_Variables.Set ("SECRETS_PASSPHRASE", "hunter2");
      Config_Secrets.Open_Vault (S, V, R);
      Assert (R = Secrets.Store.Ok, "open vault ok: " & Secrets.Store.Id (R));

      --  db.password is in the vault -> the vault value wins over config's.
      Assert (Secrets.Values.Reveal_String
                (Config_Secrets.Get_Secret (V, S, "db.password")) = "vault-secret",
              "vault value preferred over config");
      --  smtp.host is only in config -> falls back to the store value.
      Assert (Secrets.Values.Reveal_String
                (Config_Secrets.Get_Secret (V, S, "smtp.host")) = "mail.example.com",
              "falls back to config store");

      Ada.Environment_Variables.Clear ("SECRETS_PASSPHRASE");
      if Ada.Directories.Exists (Vault_Path) then
         Ada.Directories.Delete_File (Vault_Path);
      end if;
   end Test_Vault_Backed;

   procedure Test_Vault_Errors (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (Capacity => 8, Values_Capacity => 16, Pool => 1024);
      V : Secrets.Vault.Vault (Capacity => 16);
      R : Secrets.Store.Status;
      Ok : Boolean;
   begin
      --  No vault path configured.
      Config.Store.Clear (S);
      Config.Store.Set (S, "app.name", "demo", Ok => Ok);
      Ada.Environment_Variables.Set ("SECRETS_PASSPHRASE", "hunter2");
      Config_Secrets.Open_Vault (S, V, R);
      Assert (R = Secrets.Store.Io_Failed, "no vault path -> io failed");

      --  Wrong passphrase.
      Make_Vault_And_Config (S, "right");
      Ada.Environment_Variables.Set ("SECRETS_PASSPHRASE", "wrong");
      Config_Secrets.Open_Vault (S, V, R);
      Assert (R = Secrets.Store.Auth_Failed, "wrong passphrase -> auth failed");

      --  No passphrase env at all.
      Ada.Environment_Variables.Clear ("SECRETS_PASSPHRASE");
      Config_Secrets.Open_Vault (S, V, R);
      Assert (R = Secrets.Store.Auth_Failed, "no passphrase env -> auth failed");

      if Ada.Directories.Exists (Vault_Path) then
         Ada.Directories.Delete_File (Vault_Path);
      end if;
   end Test_Vault_Errors;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test (Caller.Create ("Bridge: get secret", Test_Get_Secret'Access));
      Suite.Add_Test (Caller.Create ("Bridge: is secret", Test_Is_Secret'Access));
      Suite.Add_Test (Caller.Create ("Bridge: absent key", Test_Absent'Access));
      Suite.Add_Test (Caller.Create ("Bridge: dump redacts", Test_Dump_Redacts'Access));
      Suite.Add_Test (Caller.Create ("Bridge: vault-backed secrets", Test_Vault_Backed'Access));
      Suite.Add_Test (Caller.Create ("Bridge: vault errors", Test_Vault_Errors'Access));
   end Add_Tests;

end Bridge_Tests;
