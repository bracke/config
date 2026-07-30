with Config.Keys;
with Config.Values;
with Config.Parsers.Scan;

package body Config.Parsers.Dotenv is

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result)
   is
      Line_No : Natural := 0;
      Pos     : Integer := Text'First;
   begin
      Result := (Status => Parsed, Line => 0);

      while Pos <= Text'Last loop
         --  Slice off one line (to LF), stripping a trailing CR.
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
                  Raw : constant String := Text (Pos .. Line_End);
                  T   : constant String := Scan.Trim (Raw);
               begin
                  if T'Length /= 0 and then T (T'First) /= '#' then
                     --  Optional "export " prefix.
                     declare
                        Body_Str : constant String :=
                          (if T'Length > 7
                             and then T (T'First .. T'First + 6) = "export "
                           then Scan.Trim (T (T'First + 7 .. T'Last))
                           else T);
                        Eq : Natural := 0;
                     begin
                        for I in Body_Str'Range loop
                           if Body_Str (I) = '=' then
                              Eq := I;
                              exit;
                           end if;
                        end loop;

                        if Eq = 0 then
                           Result := (Malformed, Line_No);
                           return;
                        end if;

                        declare
                           Key      : constant String :=
                             Scan.Trim (Body_Str (Body_Str'First .. Eq - 1));
                           Val_Part : constant String :=
                             Scan.Trim (Body_Str (Eq + 1 .. Body_Str'Last));
                           Buf  : String (1 .. Val_Part'Length);
                           Last : Natural;
                           Ok   : Boolean;
                        begin
                           Scan.Unquote (Val_Part, Buf, Last, Ok);
                           if not Ok
                             or else not Config.Keys.Is_Valid_Key (Key)
                           then
                              Result := (Malformed, Line_No);
                              return;
                           end if;
                           Config.Store.Set
                             (Into, Key, Buf (1 .. Last),
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

end Config.Parsers.Dotenv;
