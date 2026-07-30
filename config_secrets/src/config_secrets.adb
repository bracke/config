with Ada.Environment_Variables;
with Secrets.Values;
with Secrets_File;

package body Config_Secrets is

   use type Secrets.Store.Status;

   function Get_Secret (S : Store; Key : String) return Secrets.Values.Secret is
   begin
      if Config.Store.Has (S, Key)
        and then Config.Store.Value_Count (S, Key) >= 1
      then
         return Secrets.Values.From_String (Config.Store.Value (S, Key, 1));
      else
         return Secrets.Values.Empty;
      end if;
   end Get_Secret;

   function Is_Secret (S : Store; Key : String) return Boolean is
     (Config.Store.Has (S, Key) and then Config.Store.Is_Secret (S, Key));

   procedure Open_Vault
     (S              : Store;
      Vault          : in out Secrets.Vault.Vault;
      Result         : out Secrets.Store.Status;
      Path_Key       : String := "secrets.vault_file";
      Passphrase_Env : String := "SECRETS_PASSPHRASE")
   is
   begin
      if not Config.Store.Has (S, Path_Key)
        or else Config.Store.Value_Count (S, Path_Key) < 1
      then
         Result := Secrets.Store.Io_Failed;   --  no vault path configured
         return;
      end if;
      if not Ada.Environment_Variables.Exists (Passphrase_Env) then
         Result := Secrets.Store.Auth_Failed;  --  no passphrase available
         return;
      end if;

      declare
         Path : constant String := Config.Store.Value (S, Path_Key, 1);
         Pass : constant Secrets.Values.Secret :=
           Secrets.Values.From_String
             (Ada.Environment_Variables.Value (Passphrase_Env));
      begin
         Secrets_File.Load_With_Passphrase (Vault, Path, Pass, Result);
      end;
   end Open_Vault;

   function Get_Secret
     (Vault : Secrets.Vault.Vault;
      S     : Store;
      Key   : String) return Secrets.Values.Secret
   is
      Val : Secrets.Values.Secret;
      R   : Secrets.Store.Status;
   begin
      if Vault.Contains (Key) then
         Vault.Get (Key, Val, R);
         if R = Secrets.Store.Ok then
            return Val;
         end if;
      end if;
      return Get_Secret (S, Key);
   end Get_Secret;

end Config_Secrets;
