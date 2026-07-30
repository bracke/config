package body Config.Sources.Memory is

   use Config.Store;

   procedure Set
     (Self   : in out Source;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      Secret : Boolean := False;
      Ok     : out Boolean) is
   begin
      Config.Store.Set
        (Self.Staged, Key, Value, Kind, From => 0, Secret => Secret, Ok => Ok);
   end Set;

   procedure Append
     (Self   : in out Source;
      Key    : String;
      Value  : String;
      Kind   : Config.Values.Value_Kind := Config.Values.String_Value;
      Secret : Boolean := False;
      Ok     : out Boolean) is
   begin
      Config.Store.Append
        (Self.Staged, Key, Value, Kind, From => 0, Secret => Secret, Ok => Ok);
   end Append;

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean)
   is
      Step_Ok : Boolean;
   begin
      Ok := True;
      for I in 1 .. Count (Self.Staged) loop
         declare
            Key : constant String := Key_At (Self.Staged, I);
            K   : constant Config.Values.Value_Kind := Kind (Self.Staged, Key);
            Sec : constant Boolean := Is_Secret (Self.Staged, Key);
            NV  : constant Natural := Value_Count (Self.Staged, Key);
         begin
            for J in 1 .. NV loop
               if J = 1 then
                  Config.Store.Set
                    (Into, Key, Value (Self.Staged, Key, J), K, Id, Sec, Step_Ok);
               else
                  Config.Store.Append
                    (Into, Key, Value (Self.Staged, Key, J), K, Id, Sec, Step_Ok);
               end if;
               Ok := Ok and then Step_Ok;
            end loop;
         end;
      end loop;
   end Load;

end Config.Sources.Memory;
