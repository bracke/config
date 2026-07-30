with AUnit.Run;
with AUnit.Reporter.Text;
with AUnit.Test_Suites;
with Bridge_Tests;

procedure Tests is
   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      S : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Bridge_Tests.Add_Tests (S);
      return S;
   end Suite;

   procedure Run is new AUnit.Run.Test_Runner (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   Run (Reporter);
end Tests;
