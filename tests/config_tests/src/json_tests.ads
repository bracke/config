with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 5 tests: the JSON source (via representation) — nested objects flatten
--  to dotted keys, scalar arrays become value lists, numbers are typed, nulls
--  omitted (CFG-INV-008/009); malformed JSON and unsupported structures are
--  reported, never raised (CFG-INV-007).
package Json_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Json_Object (Item : in out Fixture);
   procedure Test_Json_Arrays (Item : in out Fixture);
   procedure Test_Json_Errors (Item : in out Fixture);

end Json_Tests;
