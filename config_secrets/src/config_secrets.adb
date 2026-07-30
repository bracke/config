package body Config_Secrets is

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

end Config_Secrets;
