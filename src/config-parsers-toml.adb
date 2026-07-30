with Interfaces; use type Interfaces.Integer_64;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Config.Keys;
with Config.Values;

package body Config.Parsers.Toml is

   NUL : constant Character := ASCII.NUL;
   LF  : constant Character := ASCII.LF;
   CR  : constant Character := ASCII.CR;
   HT  : constant Character := ASCII.HT;

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result)
   is
      Pos     : Integer := Text'First;
      Line    : Natural := 1;
      Failed  : Boolean := False;
      Prefix  : String (1 .. Natural (Config.Key_Length'Last));
      Pfx_Len : Natural := 0;

      function Peek return Character is
        (if Pos <= Text'Last then Text (Pos) else NUL);

      function Peek_At (K : Natural) return Character is
        (if Pos + K <= Text'Last then Text (Pos + K) else NUL);

      procedure Advance is
      begin
         if Pos <= Text'Last then
            if Text (Pos) = LF then
               Line := Line + 1;
            end if;
            Pos := Pos + 1;
         end if;
      end Advance;

      procedure Fail (St : Parse_Status) is
      begin
         if not Failed then
            Failed := True;
            Result := (St, Line);
         end if;
      end Fail;

      procedure Skip_Spaces is
      begin
         while Peek = ' ' or else Peek = HT or else Peek = CR loop
            Advance;
         end loop;
      end Skip_Spaces;

      procedure Skip_To_EOL is
      begin
         while Pos <= Text'Last and then Peek /= LF loop
            Advance;
         end loop;
      end Skip_To_EOL;

      --  Skip blank lines, inline whitespace, and comments between statements.
      procedure Skip_Between is
      begin
         loop
            Skip_Spaces;
            if Peek = '#' then
               Skip_To_EOL;
            elsif Peek = LF then
               Advance;
            else
               exit;
            end if;
         end loop;
      end Skip_Between;

      --  After a statement: optional spaces + comment, then newline or EOF.
      procedure Expect_End_Of_Line is
      begin
         Skip_Spaces;
         if Peek = '#' then
            Skip_To_EOL;
         end if;
         if Pos > Text'Last then
            null;
         elsif Peek = LF then
            Advance;
         else
            Fail (Malformed);
         end if;
      end Expect_End_Of_Line;

      ------------------------------------------------------------------
      --  Strings
      ------------------------------------------------------------------

      procedure Emit_Escape (R : in out Unbounded_String; C : Character) is
      begin
         case C is
            when 'n' => Append (R, LF);
            when 't' => Append (R, HT);
            when 'r' => Append (R, CR);
            when 'b' => Append (R, Character'Val (8));
            when 'f' => Append (R, Character'Val (12));
            when '"' => Append (R, '"');
            when '\' => Append (R, '\');
            when others => Append (R, '\'); Append (R, C);  --  lenient
         end case;
      end Emit_Escape;

      --  Peek = '"'. Reads a basic string (single-line or """multiline""").
      function Basic_String return String is
         R : Unbounded_String;
      begin
         if Peek_At (1) = '"' and then Peek_At (2) = '"' then
            Advance; Advance; Advance;                   --  opening """
            if Peek = LF then
               Advance;                                  --  trim one leading NL
            end if;
            loop
               if Pos > Text'Last then
                  Fail (Malformed); exit;
               elsif Peek = '"' and then Peek_At (1) = '"'
                 and then Peek_At (2) = '"'
               then
                  Advance; Advance; Advance; exit;       --  closing """
               elsif Peek = '\' then
                  Advance; Emit_Escape (R, Peek); Advance;
               else
                  Append (R, Peek); Advance;
               end if;
            end loop;
         else
            Advance;                                     --  opening "
            loop
               if Pos > Text'Last or else Peek = LF then
                  Fail (Malformed); exit;
               elsif Peek = '"' then
                  Advance; exit;
               elsif Peek = '\' then
                  Advance; Emit_Escape (R, Peek); Advance;
               else
                  Append (R, Peek); Advance;
               end if;
            end loop;
         end if;
         return To_String (R);
      end Basic_String;

      --  Peek = '''. Reads a literal string (single-line or '''multiline''').
      function Literal_String return String is
         R : Unbounded_String;
      begin
         if Peek_At (1) = ''' and then Peek_At (2) = ''' then
            Advance; Advance; Advance;
            if Peek = LF then
               Advance;
            end if;
            loop
               if Pos > Text'Last then
                  Fail (Malformed); exit;
               elsif Peek = ''' and then Peek_At (1) = '''
                 and then Peek_At (2) = '''
               then
                  Advance; Advance; Advance; exit;
               else
                  Append (R, Peek); Advance;
               end if;
            end loop;
         else
            Advance;
            loop
               if Pos > Text'Last or else Peek = LF then
                  Fail (Malformed); exit;
               elsif Peek = ''' then
                  Advance; exit;
               else
                  Append (R, Peek); Advance;
               end if;
            end loop;
         end if;
         return To_String (R);
      end Literal_String;

      ------------------------------------------------------------------
      --  Keys
      ------------------------------------------------------------------

      function Key_Segment return String is
         R : Unbounded_String;
      begin
         if Peek = '"' then
            return Basic_String;
         elsif Peek = ''' then
            return Literal_String;
         else
            while Peek in 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_' | '-' loop
               Append (R, Peek); Advance;
            end loop;
            if Length (R) = 0 then
               Fail (Malformed);
            end if;
            return To_String (R);
         end if;
      end Key_Segment;

      function Dotted_Key return String is
         R : Unbounded_String := To_Unbounded_String (Key_Segment);
      begin
         loop
            Skip_Spaces;
            exit when Peek /= '.';
            Advance;               --  the dot
            Skip_Spaces;
            Append (R, '.');
            Append (R, Key_Segment);
            exit when Failed;
         end loop;
         return To_String (R);
      end Dotted_Key;

      ------------------------------------------------------------------
      --  Atoms (numbers / booleans / datetimes)
      ------------------------------------------------------------------

      function Read_Atom return String is
         R : Unbounded_String;
      begin
         while Pos <= Text'Last
           and then Peek not in ' ' | HT | CR | LF | ',' | ']' | '}' | '#'
         loop
            Append (R, Peek); Advance;
         end loop;
         return To_String (R);
      end Read_Atom;

      function Strip_Underscores (S : String) return String is
         R : Unbounded_String;
      begin
         for C of S loop
            if C /= '_' then
               Append (R, C);
            end if;
         end loop;
         return To_String (R);
      end Strip_Underscores;

      function Is_Datetime (S : String) return Boolean is
      begin
         for I in S'First + 1 .. S'Last loop
            if S (I) = ':' then
               return True;
            elsif S (I) = '-' and then S (I - 1) in '0' .. '9' then
               return True;
            end if;
         end loop;
         return False;
      end Is_Datetime;

      procedure Parse_Int
        (Atom : String; Value : out Interfaces.Integer_64; Ok : out Boolean)
      is
         I    : Integer := Atom'First;
         Neg  : Boolean := False;
         Base : Interfaces.Integer_64 := 10;
         Any  : Boolean := False;
      begin
         Value := 0;
         Ok := False;
         if I > Atom'Last then
            return;
         end if;
         if Atom (I) = '+' or else Atom (I) = '-' then
            Neg := Atom (I) = '-';
            I := I + 1;
         end if;
         if I + 1 <= Atom'Last and then Atom (I) = '0'
           and then Atom (I + 1) in 'x' | 'o' | 'b'
         then
            Base := (case Atom (I + 1) is
                        when 'x' => 16, when 'o' => 8, when others => 2);
            I := I + 2;
         end if;
         begin
            while I <= Atom'Last loop
               declare
                  C : constant Character := Atom (I);
                  D : Interfaces.Integer_64;
               begin
                  if C = '_' then
                     null;
                  else
                     if C in '0' .. '9' then
                        D := Interfaces.Integer_64 (Character'Pos (C) - Character'Pos ('0'));
                     elsif C in 'a' .. 'f' then
                        D := Interfaces.Integer_64 (Character'Pos (C) - Character'Pos ('a') + 10);
                     elsif C in 'A' .. 'F' then
                        D := Interfaces.Integer_64 (Character'Pos (C) - Character'Pos ('A') + 10);
                     else
                        return;
                     end if;
                     if D >= Base then
                        return;
                     end if;
                     Value := Value * Base + D;
                     Any := True;
                  end if;
               end;
               I := I + 1;
            end loop;
         exception
            when others =>
               Ok := False;
               return;
         end;
         if not Any then
            return;
         end if;
         if Neg then
            Value := -Value;
         end if;
         Ok := True;
      end Parse_Int;

      --  Classify an atom and store it under Key (or append if As_Elem).
      procedure Emit (Key : String; Text_Val : String;
                      Kind : Config.Values.Value_Kind; As_Elem : Boolean);

      procedure Emit_Atom (Key : String; Atom : String; As_Elem : Boolean) is
         IV : Interfaces.Integer_64;
         Ok : Boolean;
      begin
         if Atom'Length = 0 then
            Fail (Malformed);
            return;
         elsif Atom = "true" or else Atom = "false" then
            Emit (Key, Atom, Config.Values.Boolean_Value, As_Elem);
         elsif Is_Datetime (Atom) then
            Emit (Key, Atom, Config.Values.Datetime_Value, As_Elem);
         else
            declare
               Cleaned : constant String := Strip_Underscores (Atom);
               Has_Dot : Boolean := False;
            begin
               for C of Cleaned loop
                  if C = '.' or else C = 'e' or else C = 'E' then
                     Has_Dot := True;
                  end if;
               end loop;
               if not Has_Dot then
                  Parse_Int (Atom, IV, Ok);
                  if Ok then
                     declare
                        Img : constant String :=
                          Interfaces.Integer_64'Image (IV);
                        Dec : constant String :=
                          (if Img (Img'First) = ' '
                           then Img (Img'First + 1 .. Img'Last) else Img);
                     begin
                        Emit (Key, Dec, Config.Values.Integer_Value, As_Elem);
                     end;
                  else
                     Emit (Key, Cleaned, Config.Values.Float_Value, As_Elem);
                  end if;
               else
                  Emit (Key, Cleaned, Config.Values.Float_Value, As_Elem);
               end if;
            end;
         end if;
      end Emit_Atom;

      procedure Emit (Key : String; Text_Val : String;
                      Kind : Config.Values.Value_Kind; As_Elem : Boolean)
      is
         Ok : Boolean;
      begin
         if not Config.Keys.Is_Valid_Key (Key) then
            Fail (Malformed);
            return;
         end if;
         if As_Elem then
            Config.Store.Append (Into, Key, Text_Val, Kind, Id, False, Ok);
         else
            Config.Store.Set (Into, Key, Text_Val, Kind, Id, False, Ok);
         end if;
         if not Ok then
            Fail (Overflow);
         end if;
      end Emit;

      ------------------------------------------------------------------
      --  Values, arrays, inline tables
      ------------------------------------------------------------------

      procedure Parse_Value (Key : String);

      procedure Parse_Array (Key : String) is
      begin
         Advance;                          --  consume '['
         loop
            Skip_Between;
            exit when Failed;
            if Peek = ']' then
               Advance; exit;
            elsif Peek = '"' then
               Emit (Key, Basic_String, Config.Values.String_Value, True);
            elsif Peek = ''' then
               Emit (Key, Literal_String, Config.Values.String_Value, True);
            elsif Peek = '[' or else Peek = '{' then
               Fail (Malformed);          --  nested array / table unsupported
            else
               Emit_Atom (Key, Read_Atom, True);
            end if;
            exit when Failed;
            Skip_Between;
            if Peek = ',' then
               Advance;
            elsif Peek = ']' then
               Advance; exit;
            else
               Fail (Malformed); exit;
            end if;
         end loop;
      end Parse_Array;

      procedure Parse_Inline_Table (Key : String) is
      begin
         Advance;                          --  consume '{'
         Skip_Spaces;
         if Peek = '}' then
            Advance; return;
         end if;
         loop
            Skip_Spaces;
            declare
               Member : constant String := Dotted_Key;
            begin
               exit when Failed;
               Skip_Spaces;
               if Peek /= '=' then
                  Fail (Malformed); exit;
               end if;
               Advance;
               Skip_Spaces;
               Parse_Value (Key & "." & Member);
            end;
            exit when Failed;
            Skip_Spaces;
            if Peek = ',' then
               Advance;
            elsif Peek = '}' then
               Advance; exit;
            else
               Fail (Malformed); exit;
            end if;
         end loop;
      end Parse_Inline_Table;

      procedure Parse_Value (Key : String) is
      begin
         if Peek = '"' then
            Emit (Key, Basic_String, Config.Values.String_Value, False);
         elsif Peek = ''' then
            Emit (Key, Literal_String, Config.Values.String_Value, False);
         elsif Peek = '[' then
            Parse_Array (Key);
         elsif Peek = '{' then
            Parse_Inline_Table (Key);
         else
            Emit_Atom (Key, Read_Atom, False);
         end if;
      end Parse_Value;

      ------------------------------------------------------------------
      --  Statements
      ------------------------------------------------------------------

      procedure Parse_Table_Header is
      begin
         Advance;                          --  consume '['
         if Peek = '[' then
            Fail (Malformed);              --  array-of-tables unsupported
            return;
         end if;
         Skip_Spaces;
         declare
            Name : constant String := Dotted_Key;
         begin
            if Failed then
               return;
            end if;
            Skip_Spaces;
            if Peek /= ']' then
               Fail (Malformed);
               return;
            end if;
            Advance;                        --  consume ']'
            if not Config.Keys.Is_Valid_Key (Name) then
               Fail (Malformed);
               return;
            end if;
            Prefix (1 .. Name'Length) := Name;
            Pfx_Len := Name'Length;
         end;
      end Parse_Table_Header;

      procedure Parse_Key_Value is
         K : constant String := Dotted_Key;
      begin
         if Failed then
            return;
         end if;
         Skip_Spaces;
         if Peek /= '=' then
            Fail (Malformed);
            return;
         end if;
         Advance;
         Skip_Spaces;
         declare
            Full : constant String :=
              (if Pfx_Len > 0 then Prefix (1 .. Pfx_Len) & "." & K else K);
         begin
            Parse_Value (Full);
         end;
      end Parse_Key_Value;

   begin
      Result := (Status => Parsed, Line => 0);
      loop
         Skip_Between;
         exit when Failed or else Pos > Text'Last;
         if Peek = '[' then
            Parse_Table_Header;
         else
            Parse_Key_Value;
         end if;
         exit when Failed;
         Expect_End_Of_Line;
         exit when Failed;
      end loop;
   end Parse;

end Config.Parsers.Toml;
