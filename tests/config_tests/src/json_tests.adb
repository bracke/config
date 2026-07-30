with Interfaces; use type Interfaces.Integer_64;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Values;
with Config.Reader;
with Config.Parsers; use Config.Parsers;
with Config.Parsers.Json;

package body Json_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   use type Config.Values.Value_Kind;

   procedure Test_Json_Object (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 2048);
      R : Parse_Result;
      Text : constant String :=
        "{""server"": {""host"": ""localhost"", ""port"": 8080,"
        & " ""tls"": {""enabled"": true}}, ""ratio"": 0.25,"
        & " ""missing"": null}";
   begin
      Config.Parsers.Json.Parse (Text, S, Id => 5, Result => R);
      Assert (R.Status = Parsed, "parsed clean, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_String (S, "server.host") = "localhost",
              "nested host");
      Assert (Config.Reader.Get_Integer (S, "server.port", 0) = 8080, "port");
      Assert (Config.Store.Kind (S, "server.port") = Config.Values.Integer_Value,
              "int kind");
      Assert (Config.Reader.Get_Boolean (S, "server.tls.enabled", False),
              "deep nested bool");
      Assert (Config.Store.Kind (S, "ratio") = Config.Values.Float_Value,
              "float kind");
      Assert (not Config.Store.Has (S, "missing"), "null member omitted");
      Assert (Config.Store.Provenance (S, "server.host") = 5, "provenance");
   end Test_Json_Object;

   procedure Test_Json_Arrays (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 1024);
      R : Parse_Result;
   begin
      Config.Parsers.Json.Parse
        ("{""hosts"": [""a"", ""b"", ""c""], ""ports"": [1, 2]}", S, 5, R);
      Assert (R.Status = Parsed, "arrays parsed");
      Assert (Config.Store.Value_Count (S, "hosts") = 3, "3 hosts");
      Assert (Config.Store.Value (S, "hosts", 2) = "b", "host 2");
      Assert (Config.Store.Value_Count (S, "ports") = 2, "2 ports");
      Assert (Config.Store.Value (S, "ports", 1) = "1", "port 1");
   end Test_Json_Arrays;

   procedure Test_Json_Errors (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 1024);
      R : Parse_Result;
   begin
      --  malformed JSON
      Config.Parsers.Json.Parse ("{""a"": }", S, 5, R);
      Assert (R.Status = Malformed, "malformed JSON reported");
      --  root not an object
      Config.Parsers.Json.Parse ("[1, 2, 3]", S, 5, R);
      Assert (R.Status = Malformed, "non-object root rejected");
      --  unsupported: array containing an object
      Config.Parsers.Json.Parse ("{""x"": [{""y"": 1}]}", S, 5, R);
      Assert (R.Status = Malformed, "array-of-object unsupported");
   end Test_Json_Errors;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test (Caller.Create ("Json: object", Test_Json_Object'Access));
      Suite.Add_Test (Caller.Create ("Json: arrays", Test_Json_Arrays'Access));
      Suite.Add_Test (Caller.Create ("Json: errors", Test_Json_Errors'Access));
   end Add_Tests;

end Json_Tests;
