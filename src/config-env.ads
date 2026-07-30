--  Config.Env — map an environment-variable name to a dotted config key. This
--  is the pure naming policy (no environment reading, which lives in
--  config_runtime): strip an optional prefix, lowercase, and turn '_' into the
--  hierarchy separator '.'. So with prefix "MYAPP_", `MYAPP_SERVER_PORT` becomes
--  `server.port`. Returns "" when the name does not match the prefix or the
--  mapped key is not a valid config key.
package Config.Env
  with Pure
is

   --  The dotted config key for an environment variable name, or "" if it does
   --  not apply.
   --  @param Name   The environment variable name.
   --  @param Prefix Required leading prefix ("" matches every variable).
   --  @return The mapped dotted key, or "".
   function Key_Of (Name : String; Prefix : String := "") return String;

end Config.Env;
