with Config.Keys;
with Config.Values;
with Config.Parsers.Scan;

package body Config.Parsers.Ini is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result)
   is
      Line_No : Natural := 0;
      Pos     : Integer := Text'First;
      Section : String (1 .. Natural (Config.Key_Length'Last));
      Sec_Len : Natural := 0;
   begin
      Result := (Status => Parsed, Line => 0);

      while Pos <= Text'Last loop
         declare
            EOL : Integer := Pos;
         begin
            while EOL <= Text'Last and then Text (EOL) /= ASCII.LF loop
               EOL := EOL + 1;
            end loop;
            declare
               Line_End : Integer := EOL - 1;
            begin
               if Line_End >= Pos and then Text (Line_End) = ASCII.CR then
                  Line_End := Line_End - 1;
               end if;
               Line_No := Line_No + 1;

               declare
                  T : constant String := Scan.Trim (Text (Pos .. Line_End));
               begin
                  if T'Length = 0
                    or else T (T'First) = '#' or else T (T'First) = ';'
                  then
                     null;   --  blank or comment

                  elsif T (T'First) = '[' then
                     if T (T'Last) /= ']' then
                        Result := (Malformed, Line_No);
                        return;
                     end if;
                     declare
                        Inner : constant String :=
                          Scan.Trim (T (T'First + 1 .. T'Last - 1));
                     begin
                        if Inner'Length = 0 then
                           Sec_Len := 0;   --  global section
                        elsif Config.Keys.Is_Valid_Key (Inner) then
                           Section (1 .. Inner'Length) := Inner;
                           Sec_Len := Inner'Length;
                        else
                           Result := (Malformed, Line_No);
                           return;
                        end if;
                     end;

                  else
                     declare
                        Eq : Natural := 0;
                     begin
                        for I in T'Range loop
                           if T (I) = '=' then
                              Eq := I;
                              exit;
                           end if;
                        end loop;
                        if Eq = 0 then
                           Result := (Malformed, Line_No);
                           return;
                        end if;

                        declare
                           Raw_Key  : constant String :=
                             Scan.Trim (T (T'First .. Eq - 1));
                           Val_Part : constant String :=
                             Scan.Trim (T (Eq + 1 .. T'Last));
                           Full_Key : constant String :=
                             (if Sec_Len > 0
                              then Section (1 .. Sec_Len) & "." & Raw_Key
                              else Raw_Key);
                           Buf  : String (1 .. Val_Part'Length);
                           Last : Natural;
                           Ok   : Boolean;
                        begin
                           Scan.Unquote (Val_Part, Buf, Last, Ok);
                           if not Ok
                             or else not Config.Keys.Is_Valid_Key (Full_Key)
                           then
                              Result := (Malformed, Line_No);
                              return;
                           end if;
                           Config.Store.Set
                             (Into, Full_Key, Buf (1 .. Last),
                              Config.Values.String_Value, Id, False, Ok);
                           if not Ok then
                              Result := (Overflow, Line_No);
                              return;
                           end if;
                        end;
                     end;
                  end if;
               end;

               Pos := EOL + 1;
            end;
         end;
      end loop;
   end Parse;

end Config.Parsers.Ini;
