with Interfaces; use type Interfaces.Integer_64;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Reader;
with Config.Parsers; use Config.Parsers;
with Config.Parsers.Dotenv;
with Config.Parsers.Ini;

package body Parser_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   LF : constant Character := ASCII.LF;

   procedure Test_Dotenv (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 1024);
      R : Parse_Result;
      Text : constant String :=
        "# a comment" & LF
        & "server.host=localhost" & LF
        & "export server.port = 8080" & LF
        & "greeting=""hello world""" & LF
        & "literal='no $escapes'" & LF
        & "quoted_nl=""a\nb""" & LF
        & "" & LF
        & "empty=";
   begin
      Config.Parsers.Dotenv.Parse (Text, S, Id => 1, Result => R);
      Assert (R.Status = Parsed, "parsed clean, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_String (S, "server.host") = "localhost", "host");
      Assert (Config.Reader.Get_Integer (S, "server.port", 0) = 8080, "port");
      Assert (Config.Reader.Get_String (S, "greeting") = "hello world",
              "double-quoted value");
      Assert (Config.Reader.Get_String (S, "literal") = "no $escapes",
              "single-quoted literal");
      Assert (Config.Reader.Get_String (S, "quoted_nl")
              = "a" & LF & "b", "escape \\n");
      Assert (Config.Reader.Get_String (S, "empty") = "", "empty value");
   end Test_Dotenv;

   procedure Test_Dotenv_Malformed (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 512);
      R : Parse_Result;
   begin
      --  line 2 has no '='
      Config.Parsers.Dotenv.Parse ("a=1" & LF & "no_equals_here", S, 1, R);
      Assert (R.Status = Malformed, "missing '=' is malformed");
      Assert (R.Line = 2, "reported line 2, got" & Natural'Image (R.Line));

      --  unterminated quote
      Config.Parsers.Dotenv.Parse ("k=""oops", S, 1, R);
      Assert (R.Status = Malformed, "unterminated quote malformed");

      --  invalid key
      Config.Parsers.Dotenv.Parse ("bad key=1", S, 1, R);
      Assert (R.Status = Malformed, "invalid key malformed");
   end Test_Dotenv_Malformed;

   procedure Test_Ini (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (16, 32, 1024);
      R : Parse_Result;
      Text : constant String :=
        "; comment" & LF
        & "top=1" & LF
        & "[server]" & LF
        & "host = localhost" & LF
        & "port = 9090" & LF
        & "[server.tls]" & LF
        & "enabled = yes";
   begin
      Config.Parsers.Ini.Parse (Text, S, Id => 2, Result => R);
      Assert (R.Status = Parsed, "parsed clean, line" & Natural'Image (R.Line));
      Assert (Config.Reader.Get_Integer (S, "top", 0) = 1, "global key");
      Assert (Config.Reader.Get_String (S, "server.host") = "localhost",
              "sectioned host");
      Assert (Config.Reader.Get_Integer (S, "server.port", 0) = 9090, "port");
      Assert (Config.Reader.Get_Boolean (S, "server.tls.enabled", False),
              "nested section");
      Assert (Config.Store.Provenance (S, "server.host") = 2, "provenance");
   end Test_Ini;

   procedure Test_Ini_Malformed (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S : Config.Store.Store (8, 16, 512);
      R : Parse_Result;
   begin
      Config.Parsers.Ini.Parse ("[unclosed", S, 2, R);
      Assert (R.Status = Malformed, "unclosed section header");
      Config.Parsers.Ini.Parse ("novalue", S, 2, R);
      Assert (R.Status = Malformed, "line without '='");
      Config.Parsers.Ini.Parse ("[bad section]" & LF & "k=1", S, 2, R);
      Assert (R.Status = Malformed and then R.Line = 1, "invalid section name");
   end Test_Ini_Malformed;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test (Caller.Create ("Parsers: dotenv", Test_Dotenv'Access));
      Suite.Add_Test
        (Caller.Create ("Parsers: dotenv malformed",
                        Test_Dotenv_Malformed'Access));
      Suite.Add_Test (Caller.Create ("Parsers: ini", Test_Ini'Access));
      Suite.Add_Test
        (Caller.Create ("Parsers: ini malformed", Test_Ini_Malformed'Access));
   end Add_Tests;

end Parser_Tests;
