with Interfaces; use type Interfaces.Integer_64;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Values;
with Config.Reader;
with Config.Parsers; use Config.Parsers;
with Config.Parsers.Toml;

package body Toml_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   use type Config.Values.Value_Kind;

   LF : constant Character := ASCII.LF;
   TQ : constant String := String'(1 .. 3 => '"');   --  three double quotes

   procedure Test_Scalars_And_Tables (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 2048);
      R : Parse_Result;
      Text : constant String :=
        "# a comment" & LF
        & "title = ""Example""" & LF
        & "[server]" & LF
        & "host = ""localhost""  # inline comment" & LF
        & "port = 8080" & LF
        & "enabled = true" & LF
        & "[server.tls]" & LF
        & "min_version = 1.2";
   begin
      Config.Parsers.Toml.Parse (Text, S, Id => 6, Result => R);
      Assert (R.Status = Parsed, "clean parse, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_String (S, "title") = "Example", "title");
      Assert (Config.Reader.Get_String (S, "server.host") = "localhost", "host");
      Assert (Config.Reader.Get_Integer (S, "server.port", 0) = 8080, "port");
      Assert (Config.Reader.Get_Boolean (S, "server.enabled", False), "enabled");
      Assert (Config.Store.Kind (S, "server.tls.min_version")
              = Config.Values.Float_Value, "nested table float");
      Assert (Config.Store.Provenance (S, "server.port") = 6, "provenance");
   end Test_Scalars_And_Tables;

   procedure Test_Numbers (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 1024);
      R : Parse_Result;
      Text : constant String :=
        "hexv = 0xFF" & LF
        & "octv = 0o17" & LF
        & "binv = 0b1010" & LF
        & "big = 1_000_000" & LF
        & "neg = -42" & LF
        & "pi = 3.14159" & LF
        & "when = 1979-05-27T07:32:00Z";
   begin
      Config.Parsers.Toml.Parse (Text, S, 6, R);
      Assert (R.Status = Parsed, "numbers parse, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_Integer (S, "hexv", 0) = 255, "hex -> 255");
      Assert (Config.Store.Value (S, "hexv") = "255", "hex normalised decimal");
      Assert (Config.Reader.Get_Integer (S, "octv", 0) = 15, "octal -> 15");
      Assert (Config.Reader.Get_Integer (S, "binv", 0) = 10, "binary -> 10");
      Assert (Config.Reader.Get_Integer (S, "big", 0) = 1_000_000, "underscores");
      Assert (Config.Reader.Get_Integer (S, "neg", 0) = -42, "negative");
      Assert (Config.Store.Kind (S, "pi") = Config.Values.Float_Value, "float kind");
      Assert (Config.Store.Kind (S, "when") = Config.Values.Datetime_Value,
              "datetime kind");
      Assert (Config.Reader.Get_String (S, "when") = "1979-05-27T07:32:00Z",
              "datetime text");
   end Test_Numbers;

   procedure Test_Strings (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 1024);
      R : Parse_Result;
      Text : constant String :=
        "basic = ""a\tb""" & LF
        & "lit = 'no\tescape'" & LF
        & "multi = " & TQ & "line1" & LF & "line2" & TQ;
   begin
      Config.Parsers.Toml.Parse (Text, S, 6, R);
      Assert (R.Status = Parsed, "strings parse, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_String (S, "basic") = "a" & ASCII.HT & "b",
              "basic escape processed");
      Assert (Config.Reader.Get_String (S, "lit") = "no\tescape",
              "literal keeps backslash");
      Assert (Config.Reader.Get_String (S, "multi") = "line1" & LF & "line2",
              "multiline newline preserved");
   end Test_Strings;

   procedure Test_Arrays_And_Inline (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 1024);
      R : Parse_Result;
      Text : constant String :=
        "ciphers = [""a"", ""b"", ""c""]" & LF
        & "ports = [1, 2, 3]" & LF
        & "conn = { host = ""dbhost"", port = 5432 }";
   begin
      Config.Parsers.Toml.Parse (Text, S, 6, R);
      Assert (R.Status = Parsed, "arrays parse, line" & Natural'Image (R.Line));
      Assert (Config.Store.Value_Count (S, "ciphers") = 3, "3 ciphers");
      Assert (Config.Store.Value (S, "ciphers", 2) = "b", "cipher 2");
      Assert (Config.Store.Value_Count (S, "ports") = 3, "3 ports");
      Assert (Config.Reader.Get_String (S, "conn.host") = "dbhost",
              "inline table host");
      Assert (Config.Reader.Get_Integer (S, "conn.port", 0) = 5432,
              "inline table port");
   end Test_Arrays_And_Inline;

   procedure Test_Errors (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 512);
      R : Parse_Result;
   begin
      Config.Parsers.Toml.Parse ("[[products]]" & LF & "name = ""x""", S, 6, R);
      Assert (R.Status = Malformed, "array-of-tables unsupported");
      Config.Parsers.Toml.Parse ("x = [[1, 2]]", S, 6, R);
      Assert (R.Status = Malformed, "nested array unsupported");
      Config.Parsers.Toml.Parse ("novalue", S, 6, R);
      Assert (R.Status = Malformed, "missing '='");
      Config.Parsers.Toml.Parse ("k = ""unterminated", S, 6, R);
      Assert (R.Status = Malformed, "unterminated string");
   end Test_Errors;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test
        (Caller.Create ("Toml: scalars and tables",
                        Test_Scalars_And_Tables'Access));
      Suite.Add_Test (Caller.Create ("Toml: numbers", Test_Numbers'Access));
      Suite.Add_Test (Caller.Create ("Toml: strings", Test_Strings'Access));
      Suite.Add_Test
        (Caller.Create ("Toml: arrays and inline",
                        Test_Arrays_And_Inline'Access));
      Suite.Add_Test (Caller.Create ("Toml: errors", Test_Errors'Access));
   end Add_Tests;

end Toml_Tests;
