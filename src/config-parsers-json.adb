with Representation;
with Representation.Documents;
with Representation.JSON.Documents;
with Representation.Inputs;

with Config.Keys;
with Config.Values;

package body Config.Parsers.Json is

   package Docs renames Representation.Documents;
   package JD renames Representation.JSON.Documents;
   use all type Docs.Node_Kind;

   function To_Bytes (S : String) return Representation.Byte_Array is
      B : Representation.Byte_Array (1 .. S'Length);
   begin
      for I in S'Range loop
         B (B'First + (I - S'First)) :=
           Representation.Byte (Character'Pos (S (I)));
      end loop;
      return B;
   end To_Bytes;

   function To_Str (B : Representation.Byte_Array) return String is
      S : String (1 .. B'Length);
   begin
      for I in B'Range loop
         S (S'First + (I - B'First)) := Character'Val (Integer (B (I)));
      end loop;
      return S;
   end To_Str;

   --  Kind of a JSON number text: float if it has a '.', 'e' or 'E'.
   function Number_Kind (Text : String) return Config.Values.Value_Kind is
   begin
      for C of Text loop
         if C = '.' or else C = 'e' or else C = 'E' then
            return Config.Values.Float_Value;
         end if;
      end loop;
      return Config.Values.Integer_Value;
   end Number_Kind;

   procedure Parse
     (Text   : String;
      Into   : in out Config.Store.Store;
      Id     : Config.Store.Source_Id;
      Result : out Parse_Result)
   is
      Bytes : aliased constant Representation.Byte_Array := To_Bytes (Text);
      Src   : aliased Representation.Inputs.Array_Source (Bytes'Access);
      Doc   : Docs.Document (Node_Capacity => 4096, Text_Capacity => 65_536);
      DR    : JD.Decode_Result;

      --  Value kind of a scalar node.
      function Scalar_Kind (N : Docs.Node_Ref) return Config.Values.Value_Kind is
        (case Docs.Kind (Doc, N) is
            when Number_Node => Number_Kind (To_Str (Docs.Text (Doc, N))),
            when Bool_Node   => Config.Values.Boolean_Value,
            when others      => Config.Values.String_Value);

      --  Value text of a scalar node (booleans via Bool_Value, others via Text).
      function Scalar_Text (N : Docs.Node_Ref) return String is
        (if Docs.Kind (Doc, N) = Bool_Node
         then Config.Values.Boolean_Image (Docs.Bool_Value (Doc, N))
         else To_Str (Docs.Text (Doc, N)));

      --  Assign the node at Key: recurse objects, list arrays of scalars, set
      --  scalars; skip nulls. Sets Result on the first failure.
      procedure Handle (Key : String; N : Docs.Node_Ref) is
      begin
         case Docs.Kind (Doc, N) is
            when Object_Node =>
               for I in 1 .. Docs.Length (Doc, N) loop
                  declare
                     MK   : constant String :=
                       To_Str (Docs.Member_Key (Doc, N, I));
                     Full : constant String :=
                       (if Key = "" then MK else Key & "." & MK);
                  begin
                     Handle (Full, Docs.Member (Doc, N, I));
                     if Result.Status /= Parsed then
                        return;
                     end if;
                  end;
               end loop;

            when Array_Node =>
               if not Config.Keys.Is_Valid_Key (Key) then
                  Result := (Malformed, Natural (DR.Line));
                  return;
               end if;
               for I in 1 .. Docs.Length (Doc, N) loop
                  declare
                     E : constant Docs.Node_Ref := Docs.Element (Doc, N, I);
                  begin
                     if Docs.Kind (Doc, E) = Object_Node
                       or else Docs.Kind (Doc, E) = Array_Node
                     then
                        Result := (Malformed, Natural (DR.Line));
                        return;
                     end if;
                     if Docs.Kind (Doc, E) /= Null_Node then
                        declare
                           Ok : Boolean;
                        begin
                           Config.Store.Append
                             (Into, Key, Scalar_Text (E), Scalar_Kind (E), Id,
                              False, Ok);
                           if not Ok then
                              Result := (Overflow, Natural (DR.Line));
                              return;
                           end if;
                        end;
                     end if;
                  end;
               end loop;

            when Null_Node =>
               null;   --  omit null members

            when others =>   --  a scalar
               if not Config.Keys.Is_Valid_Key (Key) then
                  Result := (Malformed, Natural (DR.Line));
                  return;
               end if;
               declare
                  Ok : Boolean;
               begin
                  Config.Store.Set
                    (Into, Key, Scalar_Text (N), Scalar_Kind (N), Id, False, Ok);
                  if not Ok then
                     Result := (Overflow, Natural (DR.Line));
                     return;
                  end if;
               end;
         end case;
      end Handle;

   begin
      Result := (Status => Parsed, Line => 0);
      JD.Decode (Doc, Src'Access, DR);
      if not DR.Ok then
         Result := (Malformed, Natural (DR.Line));
         return;
      end if;
      if Docs.Kind (Doc, DR.Root) /= Object_Node then
         Result := (Malformed, Natural (DR.Line));
         return;
      end if;
      Handle ("", DR.Root);
   end Parse;

end Config.Parsers.Json;
