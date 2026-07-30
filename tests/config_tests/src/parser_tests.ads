with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 4 tests: the dotenv and INI parsers — well-formed input parses to the
--  same store model (CFG-INV-008), quoting/comments/sections/export handled, and
--  malformed input is reported with a line number, never raised (CFG-INV-007).
package Parser_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Dotenv (Item : in out Fixture);
   procedure Test_Dotenv_Malformed (Item : in out Fixture);
   procedure Test_Ini (Item : in out Fixture);
   procedure Test_Ini_Malformed (Item : in out Fixture);

end Parser_Tests;
