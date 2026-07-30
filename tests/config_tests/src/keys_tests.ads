with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 1 tests: the dotted-key grammar (CFG-INV-001), the boolean vocabulary
--  and value-kind images, and the stable error-identifier surface.
package Keys_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Valid_Keys (Item : in out Fixture);
   procedure Test_Invalid_Keys (Item : in out Fixture);
   procedure Test_Segments (Item : in out Fixture);
   procedure Test_Boolean_Parse (Item : in out Fixture);
   procedure Test_Kind_Image (Item : in out Fixture);
   procedure Test_Error_Ids (Item : in out Fixture);

end Keys_Tests;
