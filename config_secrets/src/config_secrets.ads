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
with Config.Store;
with Secrets.Values;
package Config_Secrets is

   subtype Store is Config.Store.Store;

   --  Key's first value as a protected Secret. An absent key (or a key with no
   --  value) yields the empty Secret. Works for any key; intended for keys the
   --  store flags secret. Values longer than Secrets.Max_Secret_Bytes are
   --  truncated (as From_String does).
   function Get_Secret (S : Store; Key : String) return Secrets.Values.Secret;

   --  Whether Key exists in the store and is flagged secret.
   function Is_Secret (S : Store; Key : String) return Boolean;

end Config_Secrets;
