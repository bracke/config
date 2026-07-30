package body Config.Keys is

   function Is_Segment_Char (C : Character) return Boolean is
     (C in 'A' .. 'Z' | 'a' .. 'z' | '0' .. '9' | '_' | '-');

   function Is_Valid_Key (S : String) return Boolean is
      Seg_Len : Natural := 0;
      Segs    : Natural := 0;   --  number of separators seen
   begin
      if S'Length = 0 or else S'Length > Natural (Key_Length'Last) then
         return False;
      end if;
      for I in S'Range loop
         if S (I) = Separator then
            if Seg_Len = 0 then
               return False;   --  leading or double separator
            end if;
            Segs := Segs + 1;
            Seg_Len := 0;
         elsif Is_Segment_Char (S (I)) then
            Seg_Len := Seg_Len + 1;
            if Seg_Len > Max_Segment_Length then
               return False;
            end if;
         else
            return False;
         end if;
      end loop;
      if Seg_Len = 0 then
         return False;   --  trailing separator
      end if;
      return Segs + 1 <= Natural (Config.Segment_Count'Last);
   end Is_Valid_Key;

   function Depth (S : String) return Natural is
      Segs : Natural := 0;
   begin
      if not Is_Valid_Key (S) then
         return 0;
      end if;
      for C of S loop
         if C = Separator then
            Segs := Segs + 1;
         end if;
      end loop;
      return Segs + 1;
   end Depth;

   function Segment (S : String; Index : Positive) return String is
      Current : Natural := 1;
      Start   : Positive := S'First;
   begin
      for I in S'Range loop
         if S (I) = Separator then
            if Current = Index then
               return S (Start .. I - 1);
            end if;
            Current := Current + 1;
            Start := I + 1;
         end if;
      end loop;
      --  Last segment (no trailing separator).
      return S (Start .. S'Last);
   end Segment;

end Config.Keys;
