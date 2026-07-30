with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Tests for the config_runtime adapters: the environment source maps prefixed
--  variables to dotted keys and ignores others; the file source detects the
--  format from the extension and round-trips, and a missing optional file is not
--  an error while a missing required file is.
package Runtime_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   function Suite return AUnit.Test_Suites.Access_Test_Suite;

   procedure Test_Environment (Item : in out Fixture);
   procedure Test_File_Roundtrip (Item : in out Fixture);
   procedure Test_File_Missing (Item : in out Fixture);

end Runtime_Tests;
