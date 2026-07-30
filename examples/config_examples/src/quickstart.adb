--  Quickstart — the Phase 0 foundation using public interfaces only. Later
--  phases build a layered store from defaults/files/environment, then read
--  typed values with provenance and redaction; this example is exercised by the
--  release checks.
with Ada.Text_IO; use Ada.Text_IO;

with Config;

procedure Quickstart is
begin
   Put_Line ("config " & Config.Library_Version
             & "  (API version" & Integer'Image (Config.API_Version) & ")");
   Put_Line ("bounded limits:");
   Put_Line ("  max entries:  "
             & Config.Entry_Count'Image (Config.Entry_Count'Last));
   Put_Line ("  max sources:  "
             & Config.Source_Count'Image (Config.Source_Count'Last));
   Put_Line ("  max key len:  "
             & Config.Key_Length'Image (Config.Key_Length'Last));
   Put_Line ("  max value len:"
             & Config.Value_Length'Image (Config.Value_Length'Last));
end Quickstart;
