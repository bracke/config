with Ada.Command_Line;
with AUnit;
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

   --  Test_Runner exits 0 however many assertions failed; take the status
   --  and fail the process on anything but success.
   function Run is new AUnit.Run.Test_Runner_With_Status (Suite);
   Reporter : AUnit.Reporter.Text.Text_Reporter;
   use type AUnit.Status;
begin
   if Run (Reporter) /= AUnit.Success then
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Tests;
