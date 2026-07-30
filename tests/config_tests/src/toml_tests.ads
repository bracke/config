with AUnit.Test_Fixtures;
with AUnit.Test_Suites;

--  Phase 6 tests: the TOML parser — tables, dotted keys, string kinds (basic /
--  literal / multiline), typed integers (dec/hex/oct/bin, underscores, sign,
--  normalised to decimal), floats, booleans, datetimes, scalar arrays, and
--  inline tables, all mapping to the store model (CFG-INV-008); unsupported
--  (array-of-tables, nested array) and malformed input reported, not raised
--  (CFG-INV-007).
package Toml_Tests is

   type Fixture is new AUnit.Test_Fixtures.Test_Fixture with null record;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite);

   procedure Test_Scalars_And_Tables (Item : in out Fixture);
   procedure Test_Numbers (Item : in out Fixture);
   procedure Test_Strings (Item : in out Fixture);
   procedure Test_Arrays_And_Inline (Item : in out Fixture);
   procedure Test_Errors (Item : in out Fixture);

end Toml_Tests;
