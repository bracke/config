with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Tests for the config_secrets bridge: a secret config value round-trips into a
--  protected Secret, Is_Secret reflects the store flag, an absent key yields the
--  empty Secret, and Config.Reader.Dump still redacts the value.
package Bridge_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Get_Secret (Item : in out Fixture);
   procedure Test_Is_Secret (Item : in out Fixture);
   procedure Test_Absent (Item : in out Fixture);
   procedure Test_Dump_Redacts (Item : in out Fixture);

end Bridge_Tests;
