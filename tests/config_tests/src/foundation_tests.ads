with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 0 foundation smoke tests: the root vocabulary is present, bounded, and
--  consistent. Real behaviour (keys, store, sources, parsers, typed access)
--  arrives in later phases with their own suites.
package Foundation_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   --  Register the foundation tests with an AUnit suite.
   --  @param Suite Target suite.
   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   --  Library identity constants are set.
   --  @param Item AUnit fixture.
   procedure Test_Identity (Item : in out Fixture);

   --  Bounded structural counts have non-degenerate upper bounds.
   --  @param Item AUnit fixture.
   procedure Test_Bounds (Item : in out Fixture);

end Foundation_Tests;
