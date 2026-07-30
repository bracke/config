with Foundation_Tests;
with Keys_Tests;
with Store_Tests;
with Reader_Tests;
with Parser_Tests;
with Json_Tests;
with Toml_Tests;
with Hardening_Tests;

package body All_Suites is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      S : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Foundation_Tests.Add_Tests (S);
      Keys_Tests.Add_Tests (S);
      Store_Tests.Add_Tests (S);
      Reader_Tests.Add_Tests (S);
      Parser_Tests.Add_Tests (S);
      Json_Tests.Add_Tests (S);
      Toml_Tests.Add_Tests (S);
      Hardening_Tests.Add_Tests (S);
      return S;
   end Suite;

end All_Suites;
