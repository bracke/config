with Config.Keys;
with CryptoLib.Secure_Wipe;

package body Config.Store is

   --  Zero the used region of the char pool (keys + values, some secret). The
   --  stores are volatile (CryptoLib.Secure_Wipe), so the optimizer cannot
   --  elide them even when the memory is never read again.
   procedure Scrub_Pool (S : in out Store) is
   begin
      if S.Pool_Top > 0 then
         CryptoLib.Secure_Wipe.Wipe (S.Chars'Address, S.Pool_Top);
      end if;
   end Scrub_Pool;

   function Clamp (Value : String) return String is
      Max : constant Natural := Natural (Value_Length'Last);
   begin
      if Value'Length > Max then
         return Value (Value'First .. Value'First + Max - 1);
      else
         return Value;
      end if;
   end Clamp;

   function Entry_Index (S : Store; Key : String) return Natural is
   begin
      for I in 1 .. S.N loop
         declare
            E : Config_Entry renames S.Entries (I);
         begin
            if E.Key_Len = Key'Length
              and then S.Chars (E.Key_Start .. E.Key_Start + E.Key_Len - 1) = Key
            then
               return I;
            end if;
         end;
      end loop;
      return 0;
   end Entry_Index;

   --  Append Text to the char pool; caller must have checked space.
   procedure Put (S : in out Store; Text : String; Start_Out : out Positive) is
   begin
      Start_Out := (if Text'Length = 0 then 1 else S.Pool_Top + 1);
      if Text'Length > 0 then
         S.Chars (S.Pool_Top + 1 .. S.Pool_Top + Text'Length) := Text;
         S.Pool_Top := S.Pool_Top + Text'Length;
      end if;
   end Put;

   procedure Clear (S : in out Store) is
   begin
      Scrub_Pool (S);   --  wipe the old contents before reusing the arena
      S.N := 0;
      S.Slot_Top := 0;
      S.Pool_Top := 0;
   end Clear;

   overriding procedure Finalize (S : in out Store) is
   begin
      Scrub_Pool (S);
   end Finalize;

   function Count (S : Store) return Natural is (S.N);

   procedure Set
     (S      : in out Store;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      From   : Source_Id := 0;
      Secret : Boolean := False;
      Ok     : out Boolean)
   is
      V   : constant String := Clamp (Value);
      Idx : constant Natural := Entry_Index (S, Key);
      Need_Pool : constant Natural := V'Length + (if Idx = 0 then Key'Length else 0);
      VS  : Positive;
   begin
      Ok := False;
      if not Config.Keys.Is_Valid_Key (Key)
        or else S.Slot_Top >= S.Values_Capacity
        or else S.Pool_Top + Need_Pool > S.Pool
        or else (Idx = 0 and then S.N >= S.Capacity)
      then
         return;
      end if;

      Put (S, V, VS);
      S.Slot_Top := S.Slot_Top + 1;
      S.Slots (S.Slot_Top) := (Start => VS, Len => V'Length);

      if Idx = 0 then
         declare
            KS : Positive;
         begin
            Put (S, Key, KS);
            S.N := S.N + 1;
            S.Entries (S.N) :=
              (Key_Start => KS, Key_Len => Key'Length,
               Val_First => S.Slot_Top, Val_Count => 1,
               Kind => Kind, Provenance => From, Secret => Secret);
         end;
      else
         S.Entries (Idx).Val_First  := S.Slot_Top;
         S.Entries (Idx).Val_Count  := 1;
         S.Entries (Idx).Kind       := Kind;
         S.Entries (Idx).Provenance := From;
         S.Entries (Idx).Secret     := Secret;
      end if;
      Ok := True;
   end Set;

   procedure Append
     (S      : in out Store;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      From   : Source_Id := 0;
      Secret : Boolean := False;
      Ok     : out Boolean)
   is
      Idx : constant Natural := Entry_Index (S, Key);
   begin
      if Idx = 0 then
         Set (S, Key, Value, Kind, From, Secret, Ok);
         return;
      end if;

      declare
         V         : constant String := Clamp (Value);
         At_End    : constant Boolean :=
           S.Entries (Idx).Val_First + S.Entries (Idx).Val_Count - 1
           = S.Slot_Top;
         Slots_Need : constant Natural :=
           (if At_End then 1 else S.Entries (Idx).Val_Count + 1);
         VS : Positive;
      begin
         Ok := False;
         if S.Slot_Top + Slots_Need > S.Values_Capacity
           or else S.Pool_Top + V'Length > S.Pool
         then
            return;
         end if;

         Put (S, V, VS);

         if At_End then
            S.Slot_Top := S.Slot_Top + 1;
            S.Slots (S.Slot_Top) := (Start => VS, Len => V'Length);
            S.Entries (Idx).Val_Count := S.Entries (Idx).Val_Count + 1;
         else
            --  Copy the existing run to the end, then add the new value.
            declare
               New_First : constant Positive := S.Slot_Top + 1;
               Count_Old : constant Natural := S.Entries (Idx).Val_Count;
            begin
               for K in 0 .. Count_Old - 1 loop
                  S.Slots (New_First + K) :=
                    S.Slots (S.Entries (Idx).Val_First + K);
               end loop;
               S.Slots (New_First + Count_Old) := (Start => VS, Len => V'Length);
               S.Slot_Top := New_First + Count_Old;
               S.Entries (Idx).Val_First := New_First;
               S.Entries (Idx).Val_Count := Count_Old + 1;
            end;
         end if;
         Ok := True;
      end;
   end Append;

   function Has (S : Store; Key : String) return Boolean is
     (Entry_Index (S, Key) /= 0);

   function Value_Count (S : Store; Key : String) return Natural is
      Idx : constant Natural := Entry_Index (S, Key);
   begin
      return (if Idx = 0 then 0 else S.Entries (Idx).Val_Count);
   end Value_Count;

   function Value (S : Store; Key : String; Index : Positive := 1) return String
   is
      Idx  : constant Natural := Entry_Index (S, Key);
      Slot : Value_Slot renames S.Slots (S.Entries (Idx).Val_First + Index - 1);
   begin
      return S.Chars (Slot.Start .. Slot.Start + Slot.Len - 1);
   end Value;

   function Kind (S : Store; Key : String) return Config.Values.Value_Kind is
     (S.Entries (Entry_Index (S, Key)).Kind);

   function Provenance (S : Store; Key : String) return Source_Id is
     (S.Entries (Entry_Index (S, Key)).Provenance);

   function Is_Secret (S : Store; Key : String) return Boolean is
     (S.Entries (Entry_Index (S, Key)).Secret);

   function Key_At (S : Store; Index : Positive) return String is
      E : Config_Entry renames S.Entries (Index);
   begin
      return S.Chars (E.Key_Start .. E.Key_Start + E.Key_Len - 1);
   end Key_At;

end Config.Store;
