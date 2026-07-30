with Ada.Strings.Unbounded;
with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Keys;
with Config.Values;
with Config.Errors;

package body Keys_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   use Config.Keys;
   use Config.Values;

   procedure Test_Valid_Keys (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      Assert (Is_Valid_Key ("port"), "single segment");
      Assert (Is_Valid_Key ("server.http.port"), "dotted");
      Assert (Is_Valid_Key ("a_b-c.d9"), "underscore/hyphen/digit");
      Assert (Is_Valid_Key ("A.B.C"), "uppercase");
      Assert (Depth ("server.http.port") = 3, "depth 3");
      Assert (Depth ("port") = 1, "depth 1");
   end Test_Valid_Keys;

   procedure Test_Invalid_Keys (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      Assert (not Is_Valid_Key (""), "empty");
      Assert (not Is_Valid_Key (".port"), "leading dot");
      Assert (not Is_Valid_Key ("port."), "trailing dot");
      Assert (not Is_Valid_Key ("a..b"), "double dot");
      Assert (not Is_Valid_Key ("a b"), "space");
      Assert (not Is_Valid_Key ("a/b"), "slash");
      Assert (not Is_Valid_Key ("a=b"), "equals");
      Assert (Depth ("a..b") = 0, "invalid depth is 0");
   end Test_Invalid_Keys;

   procedure Test_Segments (Item : in out Fixture) is
      pragma Unreferenced (Item);
      K : constant String := "server.http.port";
   begin
      Assert (Segment (K, 1) = "server", "seg 1");
      Assert (Segment (K, 2) = "http", "seg 2");
      Assert (Segment (K, 3) = "port", "seg 3");
      Assert (Segment ("solo", 1) = "solo", "single seg");
   end Test_Segments;

   procedure Check_Bool (Text : String; Want : Boolean) is
      R, Ok : Boolean;
   begin
      Parse_Boolean (Text, R, Ok);
      Assert (Ok, "should parse: " & Text);
      Assert (R = Want, "wrong value for: " & Text);
   end Check_Bool;

   procedure Test_Boolean_Parse (Item : in out Fixture) is
      pragma Unreferenced (Item);
      R, Ok : Boolean;
   begin
      Check_Bool ("true", True);
      Check_Bool ("YES", True);
      Check_Bool ("On", True);
      Check_Bool ("1", True);
      Check_Bool ("false", False);
      Check_Bool ("no", False);
      Check_Bool ("OFF", False);
      Check_Bool ("0", False);
      Parse_Boolean ("maybe", R, Ok);
      Assert (not Ok, "invalid boolean rejected");
      Assert (Boolean_Image (True) = "true" and then Boolean_Image (False)
              = "false", "boolean image");
   end Test_Boolean_Parse;

   procedure Test_Kind_Image (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      Assert (Image (String_Value) = "string", "string");
      Assert (Image (Integer_Value) = "integer", "integer");
      Assert (Image (Float_Value) = "float", "float");
      Assert (Image (Boolean_Value) = "boolean", "boolean");
      Assert (Image (Datetime_Value) = "datetime", "datetime");
   end Test_Kind_Image;

   procedure Test_Error_Ids (Item : in out Fixture) is
      pragma Unreferenced (Item);
      use Config.Errors;
      use Ada.Strings.Unbounded;
      Ids : constant array (Positive range <>) of Unbounded_String :=
        [To_Unbounded_String (Key_Invalid),
         To_Unbounded_String (Key_Too_Long),
         To_Unbounded_String (Duplicate_Key),
         To_Unbounded_String (Value_Too_Long),
         To_Unbounded_String (Too_Many_Values),
         To_Unbounded_String (Too_Many_Entries),
         To_Unbounded_String (Too_Many_Sources),
         To_Unbounded_String (Missing_Required),
         To_Unbounded_String (Type_Mismatch),
         To_Unbounded_String (Parse_Error)];
      function Has_Prefix (S, P : String) return Boolean is
        (S'Length >= P'Length
         and then S (S'First .. S'First + P'Length - 1) = P);
   begin
      for I in Ids'Range loop
         declare
            Id : constant String := To_String (Ids (I));
         begin
            Assert (Id'Length > 0, "non-empty id");
            Assert (Has_Prefix (Id, "config."), "config-namespaced: " & Id);
         end;
         for J in I + 1 .. Ids'Last loop
            Assert (Ids (I) /= Ids (J), "distinct: " & To_String (Ids (I)));
         end loop;
      end loop;
   end Test_Error_Ids;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test (Caller.Create ("Keys: valid", Test_Valid_Keys'Access));
      Suite.Add_Test (Caller.Create ("Keys: invalid", Test_Invalid_Keys'Access));
      Suite.Add_Test (Caller.Create ("Keys: segments", Test_Segments'Access));
      Suite.Add_Test
        (Caller.Create ("Values: boolean parse", Test_Boolean_Parse'Access));
      Suite.Add_Test
        (Caller.Create ("Values: kind image", Test_Kind_Image'Access));
      Suite.Add_Test
        (Caller.Create ("Errors: stable ids", Test_Error_Ids'Access));
   end Add_Tests;

end Keys_Tests;
