with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config;
use type Config.Entry_Count;
use type Config.Value_Index;
use type Config.Source_Count;
use type Config.Segment_Count;
use type Config.Key_Length;
use type Config.Value_Length;
use type Config.Byte_Count;

package body Foundation_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);

   procedure Test_Identity (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      Assert (Config.Library_Name'Length > 0,
              "library name must be non-empty");
      Assert (Config.Library_Version'Length > 0,
              "library version must be non-empty");
      Assert (Config.API_Version'Image'Length > 0,
              "API version must be set");
   end Test_Identity;

   procedure Test_Bounds (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      Assert (Config.Entry_Count'Last > 0, "Entry_Count upper bound is zero");
      Assert (Config.Value_Index'Last > 0, "Value_Index upper bound is zero");
      Assert (Config.Source_Count'Last > 0, "Source_Count upper bound is zero");
      Assert (Config.Segment_Count'Last > 0, "Segment_Count upper bound is zero");
      Assert (Config.Key_Length'Last > 0, "Key_Length upper bound is zero");
      Assert (Config.Value_Length'Last > 0, "Value_Length upper bound is zero");
      Assert (Config.Byte_Count'Last > 0, "Byte_Count upper bound is zero");
   end Test_Bounds;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test
        (Caller.Create ("Foundation: library identity", Test_Identity'Access));
      Suite.Add_Test
        (Caller.Create ("Foundation: bounded counts", Test_Bounds'Access));
   end Add_Tests;

end Foundation_Tests;
