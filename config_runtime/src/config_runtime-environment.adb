with Ada.Environment_Variables;

with Config.Env;
with Config.Values;

package body Config_Runtime.Environment is

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean)
   is
      All_Ok : Boolean := True;

      procedure One (Name : String; Value : String) is
         Key    : constant String := Config.Env.Key_Of (Name, Self.Prefix.all);
         Set_Ok : Boolean;
      begin
         if Key /= "" then
            Config.Store.Set
              (Into, Key, Value, Config.Values.String_Value, Id, False, Set_Ok);
            All_Ok := All_Ok and then Set_Ok;
         end if;
      end One;

   begin
      Ada.Environment_Variables.Iterate (One'Access);
      Ok := All_Ok;
   end Load;

end Config_Runtime.Environment;
