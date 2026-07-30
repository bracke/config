package body Config.Parsers.Scan is

   function Is_Blank (C : Character) return Boolean is
     (C = ' ' or else C = ASCII.HT);

   function Trim (S : String) return String is
      L : Integer := S'First;
      R : Integer := S'Last;
   begin
      while L <= R and then Is_Blank (S (L)) loop
         L := L + 1;
      end loop;
      while R >= L and then Is_Blank (S (R)) loop
         R := R - 1;
      end loop;
      return S (L .. R);
   end Trim;

   procedure Unquote
     (S      : String;
      Buffer : out String;
      Last   : out Natural;
      Ok     : out Boolean)
   is
      procedure Emit (C : Character) is
      begin
         Last := Last + 1;
         Buffer (Buffer'First + Last - 1) := C;
      end Emit;
   begin
      Last := 0;
      Ok := True;

      if S'Length >= 2
        and then S (S'First) = '"' and then S (S'Last) = '"'
      then
         --  Double-quoted: process escapes over the inner content.
         declare
            I : Integer := S'First + 1;
         begin
            while I <= S'Last - 1 loop
               if S (I) = '\' and then I < S'Last - 1 then
                  I := I + 1;
                  case S (I) is
                     when 'n' => Emit (ASCII.LF);
                     when 't' => Emit (ASCII.HT);
                     when 'r' => Emit (ASCII.CR);
                     when '"' => Emit ('"');
                     when '\' => Emit ('\');
                     when others => Emit ('\'); Emit (S (I));
                  end case;
               else
                  Emit (S (I));
               end if;
               I := I + 1;
            end loop;
         end;

      elsif S'Length >= 1 and then S (S'First) = '"' then
         Ok := False;   --  opens with a quote but is not closed

      elsif S'Length >= 2
        and then S (S'First) = ''' and then S (S'Last) = '''
      then
         for I in S'First + 1 .. S'Last - 1 loop
            Emit (S (I));
         end loop;

      elsif S'Length >= 1 and then S (S'First) = ''' then
         Ok := False;

      else
         for C of S loop
            Emit (C);
         end loop;
      end if;
   end Unquote;

end Config.Parsers.Scan;
