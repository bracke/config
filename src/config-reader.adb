with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Config.Values;

package body Config.Reader is

   use Config.Store;

   function Get_String
     (S : Store; Key : String; Default : String := "") return String is
   begin
      if Has (S, Key) and then Value_Count (S, Key) >= 1 then
         return Value (S, Key, 1);
      else
         return Default;
      end if;
   end Get_String;

   procedure Get_Integer
     (S : Store; Key : String;
      Result : out Interfaces.Integer_64; Status : out Lookup_Status) is
   begin
      if not Has (S, Key) or else Value_Count (S, Key) = 0 then
         Result := 0;
         Status := Missing;
         return;
      end if;
      begin
         Result := Interfaces.Integer_64'Value (Value (S, Key, 1));
         Status := Found;
      exception
         when others =>
            Result := 0;
            Status := Invalid;
      end;
   end Get_Integer;

   function Get_Integer
     (S : Store; Key : String; Default : Interfaces.Integer_64)
      return Interfaces.Integer_64
   is
      R : Interfaces.Integer_64;
      St : Lookup_Status;
   begin
      Get_Integer (S, Key, R, St);
      return (if St = Found then R else Default);
   end Get_Integer;

   procedure Get_Float
     (S : Store; Key : String;
      Result : out Long_Float; Status : out Lookup_Status) is
   begin
      if not Has (S, Key) or else Value_Count (S, Key) = 0 then
         Result := 0.0;
         Status := Missing;
         return;
      end if;
      begin
         Result := Long_Float'Value (Value (S, Key, 1));
         Status := Found;
      exception
         when others =>
            Result := 0.0;
            Status := Invalid;
      end;
   end Get_Float;

   function Get_Float
     (S : Store; Key : String; Default : Long_Float) return Long_Float
   is
      R : Long_Float;
      St : Lookup_Status;
   begin
      Get_Float (S, Key, R, St);
      return (if St = Found then R else Default);
   end Get_Float;

   procedure Get_Boolean
     (S : Store; Key : String;
      Result : out Boolean; Status : out Lookup_Status)
   is
      Valid : Boolean;
   begin
      if not Has (S, Key) or else Value_Count (S, Key) = 0 then
         Result := False;
         Status := Missing;
         return;
      end if;
      Config.Values.Parse_Boolean (Value (S, Key, 1), Result, Valid);
      Status := (if Valid then Found else Invalid);
   end Get_Boolean;

   function Get_Boolean
     (S : Store; Key : String; Default : Boolean) return Boolean
   is
      R : Boolean;
      St : Lookup_Status;
   begin
      Get_Boolean (S, Key, R, St);
      return (if St = Found then R else Default);
   end Get_Boolean;

   function Dump (S : Store) return String is
      R : Unbounded_String;
   begin
      for I in 1 .. Count (S) loop
         declare
            Key : constant String := Key_At (S, I);
            NV  : constant Natural := Value_Count (S, Key);
         begin
            Append (R, Key & " = ");
            if Is_Secret (S, Key) then
               Append (R, Redacted);
            elsif NV = 1 then
               Append (R, Value (S, Key, 1));
            else
               Append (R, "[");
               for J in 1 .. NV loop
                  if J > 1 then
                     Append (R, ", ");
                  end if;
                  Append (R, Value (S, Key, J));
               end loop;
               Append (R, "]");
            end if;
            Append (R, ASCII.LF);
         end;
      end loop;
      return To_String (R);
   end Dump;

end Config.Reader;
