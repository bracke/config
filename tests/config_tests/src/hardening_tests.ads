with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 8 hardening: fuzz all four parsers with thousands of random byte
--  strings (structural characters included) and assert none raises and the store
--  stays bounded (CFG-INV-002/007); plus a precedence stress that repeatedly
--  layers several sources and checks last-wins with correct provenance
--  (CFG-INV-003).
package Hardening_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Parser_Fuzz (Item : in out Fixture);
   procedure Test_Precedence_Stress (Item : in out Fixture);

end Hardening_Tests;
