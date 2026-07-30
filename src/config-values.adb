package body Config.Values is

   function To_Lower (S : String) return String is
      R : String (S'Range);
   begin
      for I in S'Range loop
         R (I) :=
           (if S (I) in 'A' .. 'Z'
            then Character'Val (Character'Pos (S (I)) + 32)
            else S (I));
      end loop;
      return R;
   end To_Lower;

   procedure Parse_Boolean
     (Text : String; Result : out Boolean; Valid : out Boolean)
   is
      Lower : constant String := To_Lower (Text);
   begin
      Valid := True;
      if Lower = "true" or else Lower = "yes" or else Lower = "on"
        or else Lower = "1"
      then
         Result := True;
      elsif Lower = "false" or else Lower = "no" or else Lower = "off"
        or else Lower = "0"
      then
         Result := False;
      else
         Result := False;
         Valid := False;
      end if;
   end Parse_Boolean;

end Config.Values;
