with Config.Keys;

package body Config.Env is

   function Key_Of (Name : String; Prefix : String := "") return String is
   begin
      if Name'Length < Prefix'Length
        or else (Prefix'Length > 0
                 and then Name (Name'First .. Name'First + Prefix'Length - 1)
                          /= Prefix)
      then
         return "";
      end if;

      declare
         Rest : constant String :=
           Name (Name'First + Prefix'Length .. Name'Last);
         R    : String (Rest'Range);
      begin
         for I in Rest'Range loop
            R (I) :=
              (case Rest (I) is
                  when '_'      => '.',
                  when 'A' .. 'Z' =>
                     Character'Val (Character'Pos (Rest (I)) + 32),
                  when others   => Rest (I));
         end loop;
         return (if Config.Keys.Is_Valid_Key (R) then R else "");
      end;
   end Key_Of;

end Config.Env;
