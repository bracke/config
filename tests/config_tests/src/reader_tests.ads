with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 3 tests: the source seam + layered precedence (CFG-INV-003), typed
--  access with required-vs-default and invalid handling (CFG-INV-004/005), and
--  the redacted dump (CFG-INV-006).
package Reader_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Layered_Precedence (Item : in out Fixture);
   procedure Test_Typed_Access (Item : in out Fixture);
   procedure Test_Missing_And_Invalid (Item : in out Fixture);
   procedure Test_Redacted_Dump (Item : in out Fixture);

end Reader_Tests;
