with Interfaces; use Interfaces;

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Caller;

with Config.Store;
with Config.Reader;
with Config.Sources.Memory;
with Config.Parsers; use Config.Parsers;
with Config.Parsers.Dotenv;
with Config.Parsers.Ini;
with Config.Parsers.Json;
with Config.Parsers.Toml;

package body Hardening_Tests is

   package Caller is new AUnit.Test_Caller (Fixture);

   State : Unsigned_64 := 2_463_534_242;

   function Next return Unsigned_32 is
   begin
      State := State * 6_364_136_223_846_793_005 + 1_442_695_040_888_963_407;
      return Unsigned_32 (Shift_Right (State, 32) and 16#FFFF_FFFF#);
   end Next;

   function Below (Bound : Positive) return Natural is
     (Natural (Next mod Unsigned_32 (Bound)));

   --  Alphabet with the structural characters the parsers care about.
   Alpha : constant String :=
     "abc012.=-_[]{}""'#,: " & ASCII.LF & ASCII.HT;

   procedure Test_Parser_Fuzz (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      for Iter in 1 .. 4000 loop
         declare
            Len : constant Natural := Below (56);
            Txt : String (1 .. Len);
            St  : Config.Store.Store (8, 16, 256);
            R   : Parse_Result;
         begin
            for I in Txt'Range loop
               Txt (I) := Alpha (Alpha'First + Below (Alpha'Length));
            end loop;
            case Iter mod 4 is
               when 0 => Config.Parsers.Dotenv.Parse (Txt, St, 1, R);
               when 1 => Config.Parsers.Ini.Parse (Txt, St, 1, R);
               when 2 => Config.Parsers.Json.Parse (Txt, St, 1, R);
               when others => Config.Parsers.Toml.Parse (Txt, St, 1, R);
            end case;
            --  A parser never raises and never exceeds the store's bounds.
            Assert (Config.Store.Count (St) <= 8,
                    "store exceeded capacity at iteration"
                    & Integer'Image (Iter));
         end;
      end loop;
   end Test_Parser_Fuzz;

   procedure Test_Precedence_Stress (Item : in out Fixture) is
      pragma Unreferenced (Item);
   begin
      for Round in 1 .. 300 loop
         declare
            St : Config.Store.Store (8, 16, 512);
            Ok : Boolean;
         begin
            for Src in 1 .. 5 loop
               declare
                  M : Config.Sources.Memory.Source (4, 8, 128);
                  V : constant String :=
                    "v" & Character'Val (Character'Pos ('0') + Src);
               begin
                  M.Set ("shared.key", V, Ok => Ok);
                  M.Load (St, Src, Ok);
               end;
            end loop;
            Assert (Config.Reader.Get_String (St, "shared.key") = "v5",
                    "last source wins (round" & Integer'Image (Round) & ")");
            Assert (Config.Store.Provenance (St, "shared.key") = 5,
                    "winning provenance recorded");
         end;
      end loop;
   end Test_Precedence_Stress;

   procedure Add_Tests (Suite : AUnit.Test_Suites.Access_Test_Suite) is
   begin
      Suite.Add_Test
        (Caller.Create ("Hardening: parser fuzz (4000 inputs)",
                        Test_Parser_Fuzz'Access));
      Suite.Add_Test
        (Caller.Create ("Hardening: precedence stress",
                        Test_Precedence_Stress'Access));
   end Add_Tests;

end Hardening_Tests;
