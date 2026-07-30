with Foundation_Tests;
with Keys_Tests;

package body All_Suites is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      S : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Foundation_Tests.Add_Tests (S);
      Keys_Tests.Add_Tests (S);
      return S;
   end Suite;

end All_Suites;
