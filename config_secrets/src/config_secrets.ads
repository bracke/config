--  Config_Secrets — a bridge between the config library and the secrets library.
--
--  A config value flagged secret (Secret => True, e.g. a database password or an
--  API key) is stored and returned by the config core as a plain String, and
--  redacted only in Config.Reader.Dump. This bridge hands the same value back as
--  a protected Secrets.Values.Secret: bounded, wiped from memory when finalised,
--  never rendered by Image, and compared in constant time. Read secret settings
--  through Get_Secret instead of Config.Reader.Get_String so the material lives
--  in a Secret from the read boundary onward.
--
--  This is a bridge crate because the config core forbids cryptolib (its
--  boundary is stdlib + representation); secrets brings the cryptographic
--  primitives, so the two are joined here, outside either core.
--
--  It also lets secret values come from an encrypted vault instead of plaintext
--  config: Open_Vault decrypts a passphrase vault (secrets_file) whose path is a
--  config value, and the Get_Secret (Vault, ...) overload prefers the vault,
--  falling back to the config store.
with Config.Store;
with Secrets.Values;
with Secrets.Vault;
with Secrets.Store;
package Config_Secrets is

   subtype Store is Config.Store.Store;

   --  Key's first value as a protected Secret. An absent key (or a key with no
   --  value) yields the empty Secret. Works for any key; intended for keys the
   --  store flags secret. Values longer than Secrets.Max_Secret_Bytes are
   --  truncated (as From_String does).
   function Get_Secret (S : Store; Key : String) return Secrets.Values.Secret;

   --  Whether Key exists in the store and is flagged secret.
   function Is_Secret (S : Store; Key : String) return Boolean;

   --  Load a passphrase-encrypted secrets vault into Vault. The vault file path
   --  is the config value under Path_Key; the passphrase is taken from the
   --  environment variable Passphrase_Env (never from config, which would defeat
   --  the point). Result: Ok; Io_Failed if no path is configured or the file is
   --  missing/unreadable; Auth_Failed if the passphrase env var is unset or
   --  wrong; Vault_Full if the file has more entries than Vault's capacity.
   --  Vault is unchanged unless the load succeeds.
   procedure Open_Vault
     (S              : Store;
      Vault          : in out Secrets.Vault.Vault;
      Result         : out Secrets.Store.Status;
      Path_Key       : String := "secrets.vault_file";
      Passphrase_Env : String := "SECRETS_PASSPHRASE");

   --  A secret preferring the vault: if Vault holds Key, return that; otherwise
   --  fall back to the config store value (Get_Secret (S, Key)). Use after
   --  Open_Vault so an app reads secrets from the encrypted vault when present
   --  and from config only as a fallback.
   function Get_Secret
     (Vault : Secrets.Vault.Vault;
      S     : Store;
      Key   : String) return Secrets.Values.Secret;

end Config_Secrets;
