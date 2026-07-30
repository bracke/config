with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Values;
with Config.Store;

package body Store_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);
   use Config.Store;
   use type Config.Values.Value_Kind;

   procedure Test_Set_And_Read (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S  : Store (Capacity => 8, Values_Capacity => 16, Pool => 512);
      Ok : Boolean;
   begin
      Set (S, "server.port", "8080", Config.Values.Integer_Value, From => 2,
           Ok => Ok);
      Assert (Ok, "set port");
      Set (S, "server.host", "localhost", From => 2, Secret => False, Ok => Ok);
      Assert (Ok, "set host");
      Set (S, "db.password", "s3cr3t", From => 3, Secret => True, Ok => Ok);
      Assert (Ok, "set secret");

      Assert (Count (S) = 3, "three keys");
      Assert (Has (S, "server.port"), "has port");
      Assert (not Has (S, "missing"), "missing absent");
      Assert (Value (S, "server.port") = "8080", "port value");
      Assert (Kind (S, "server.port") = Config.Values.Integer_Value, "port kind");
      Assert (Provenance (S, "server.port") = 2, "port provenance");
      Assert (Is_Secret (S, "db.password"), "password secret");
      Assert (not Is_Secret (S, "server.host"), "host not secret");
      Assert (Value_Count (S, "server.port") = 1, "scalar count 1");
      Assert (Value_Count (S, "missing") = 0, "absent count 0");
   end Test_Set_And_Read;

   procedure Test_Override_Provenance (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S  : Store (Capacity => 4, Values_Capacity => 8, Pool => 256);
      Ok : Boolean;
   begin
      --  file layer sets it, env layer (higher precedence) overrides.
      Set (S, "port", "8080", Config.Values.Integer_Value, From => 1, Ok => Ok);
      Assert (Ok and then Value (S, "port") = "8080", "initial");
      Set (S, "port", "9090", Config.Values.Integer_Value, From => 4, Ok => Ok);
      Assert (Ok, "override");
      Assert (Count (S) = 1, "still one key");
      Assert (Value (S, "port") = "9090", "overridden value");
      Assert (Provenance (S, "port") = 4, "overriding source recorded");
   end Test_Override_Provenance;

   procedure Test_Arrays (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S  : Store (Capacity => 4, Values_Capacity => 8, Pool => 256);
      Ok : Boolean;
   begin
      Append (S, "hosts", "a", From => 1, Ok => Ok);
      Assert (Ok, "append a (creates key)");
      Append (S, "hosts", "b", Ok => Ok);
      Assert (Ok, "append b");
      Append (S, "hosts", "c", Ok => Ok);
      Assert (Ok, "append c");
      Assert (Value_Count (S, "hosts") = 3, "three values");
      Assert (Value (S, "hosts", 1) = "a", "elem 1");
      Assert (Value (S, "hosts", 2) = "b", "elem 2");
      Assert (Value (S, "hosts", 3) = "c", "elem 3");
      Assert (Provenance (S, "hosts") = 1, "array provenance from first");
   end Test_Arrays;

   procedure Test_Interleaved_Append (Item : in out Fixture) is
      pragma Unreferenced (Item);
      S  : Store (Capacity => 4, Values_Capacity => 12, Pool => 256);
      Ok : Boolean;
   begin
      --  Two arrays grown alternately: forces the non-end copy path.
      Append (S, "x", "x1", Ok => Ok);
      Append (S, "y", "y1", Ok => Ok);
      Append (S, "x", "x2", Ok => Ok);   --  x's run is no longer at the end
      Append (S, "y", "y2", Ok => Ok);
      Append (S, "x", "x3", Ok => Ok);
      Assert (Value_Count (S, "x") = 3, "x has 3");
      Assert (Value_Count (S, "y") = 2, "y has 2");
      Assert (Value (S, "x", 1) = "x1" and then Value (S, "x", 2) = "x2"
              and then Value (S, "x", 3) = "x3", "x order preserved");
      Assert (Value (S, "y", 1) = "y1" and then Value (S, "y", 2) = "y2",
              "y order preserved");
   end Test_Interleaved_Append;

   procedure Test_Bounds (Item : in out Fixture) is
      pragma Unreferenced (Item);
      Ok : Boolean;
   begin
      --  Invalid key rejected.
      declare
         S : Store (Capacity => 4, Values_Capacity => 8, Pool => 256);
      begin
         Set (S, "bad key", "v", Ok => Ok);
         Assert (not Ok, "invalid key rejected");
         Assert (Count (S) = 0, "nothing stored");
      end;
      --  Entry capacity.
      declare
         S : Store (Capacity => 2, Values_Capacity => 8, Pool => 256);
      begin
         Set (S, "a", "1", Ok => Ok); Assert (Ok, "a");
         Set (S, "b", "2", Ok => Ok); Assert (Ok, "b");
         Set (S, "c", "3", Ok => Ok);
         Assert (not Ok, "third key beyond capacity refused");
         --  overriding an existing key still works at capacity.
         Set (S, "a", "11", Ok => Ok);
         Assert (Ok and then Value (S, "a") = "11", "override at capacity");
      end;
      --  Pool exhaustion.
      declare
         S : Store (Capacity => 8, Values_Capacity => 8, Pool => 6);
      begin
         Set (S, "k", "v", Ok => Ok);      --  "k"+"v" = 2 chars
         Assert (Ok, "small fits");
         Set (S, "kk", "vvvvv", Ok => Ok); --  7 chars > 4 remaining
         Assert (not Ok, "pool exhaustion refused");
      end;
   end Test_Bounds;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test
        (Caller.Create ("Store: set and read", Test_Set_And_Read'Access));
      Suite.Add_Test
        (Caller.Create ("Store: override + provenance",
                        Test_Override_Provenance'Access));
      Suite.Add_Test (Caller.Create ("Store: arrays", Test_Arrays'Access));
      Suite.Add_Test
        (Caller.Create ("Store: interleaved append",
                        Test_Interleaved_Append'Access));
      Suite.Add_Test (Caller.Create ("Store: bounds", Test_Bounds'Access));
   end Add_Tests;

end Store_Tests;
