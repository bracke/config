with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 2 tests: the bounded store — set/read scalars, override with provenance
--  (CFG-INV-003), value arrays via Append, secret flag, key validation on set,
--  and capacity/pool/value-slot exhaustion (CFG-INV-002).
package Store_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Set_And_Read (Item : in out Fixture);
   procedure Test_Override_Provenance (Item : in out Fixture);
   procedure Test_Arrays (Item : in out Fixture);
   procedure Test_Interleaved_Append (Item : in out Fixture);
   procedure Test_Bounds (Item : in out Fixture);

end Store_Tests;
