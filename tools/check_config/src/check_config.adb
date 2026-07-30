with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO;

with GNAT.OS_Lib;

with Project_Tools.Files;
with Project_Tools.Processes;
with Project_Tools.Release_Checks;

--  Release and documentation guard for the config library. Written entirely in
--  Ada: the dependency-boundary audit scans the core sources directly. The
--  config core may depend on the Ada stdlib and `representation` only;
--  everything I/O-, environment-, transport-, or persistence-facing is forbidden
--  (that lives in the config_runtime adapter).
--
--    (default)          required-surface + dependency-boundary audit
--    --release          + build library, build/run tests, build/run examples
--    --release-strict   + require clean git worktrees (config, project_tools)
procedure Check_Config is

   use Ada.Text_IO;
   package Files renames Project_Tools.Files;
   package Proc renames Project_Tools.Processes;
   package RC renames Project_Tools.Release_Checks;

   Errors : Natural := 0;

   procedure Fail (Message : String) is
   begin
      Errors := Errors + 1;
      Put_Line (Standard_Error, "error: " & Message);
   end Fail;

   function Root return String is
      Current : constant String := Ada.Directories.Current_Directory;
      Found   : constant String := Files.Find_Root_Upward (Current, "config.gpr");
   begin
      if Found = "" then
         Put_Line (Standard_Error, "config root not found from " & Current);
         Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
         raise Program_Error;
      end if;
      return Found;
   end Root;

   The_Root : constant String := Root;

   procedure Need_File (Relative : String) is
   begin
      if not Files.File_Exists (The_Root & "/" & Relative) then
         Fail ("missing required file: " & Relative);
      end if;
   end Need_File;

   procedure Need_Directory (Relative : String) is
   begin
      if not Files.Directory_Exists (The_Root & "/" & Relative) then
         Fail ("missing required directory: " & Relative);
      end if;
   end Need_Directory;

   procedure Need_Text (Relative : String; Pattern : String) is
   begin
      if not Files.File_Contains (The_Root & "/" & Relative, Pattern) then
         Fail (Relative & " must contain: " & Pattern);
      end if;
   end Need_Text;

   function Run
     (Label   : String;
      Dir     : String;
      Program : String;
      Args    : GNAT.OS_Lib.Argument_List) return Boolean
   is
      Status : Integer;
   begin
      if Program = "" then
         Fail (Label & ": program not found");
         return False;
      end if;
      Status :=
        Proc.Run_Status
          (Label => Label, Dir => Dir, Program => Program, Args => Args);
      if Status /= 0 then
         Fail (Label & " failed (status" & Integer'Image (Status) & ")");
         return False;
      end if;
      return True;
   end Run;

   Ignored : Boolean;
   pragma Unreferenced (Ignored);

   procedure Check_Surface is
   begin
      Need_Directory ("src");
      Need_Directory ("tests/config_tests");
      Need_Directory ("config_runtime");
      Need_Directory ("config_runtime/tests/config_runtime_tests");
      Need_Directory ("config_secrets");
      Need_Directory ("tests/config_secrets_tests");
      Need_Directory ("examples/config_examples");
      Need_Directory ("tools");
      Need_Directory ("docs");
      Need_Directory ("docs/ai");
      Need_Directory ("docs/adr");
      Need_Directory ("fuzz");
      Need_Directory ("fixtures");
      Need_Directory ("invariant-registry");

      Need_File ("alire.toml");
      Need_File ("config.gpr");
      Need_File ("README.md");
      Need_File ("LICENSE");
      Need_File ("CHANGELOG.md");
      Need_File ("AI.md");
      Need_File ("SECURITY.md");
      Need_File ("CONTRIBUTING.md");
      Need_File ("src/config.ads");
      Need_File ("tests/config_tests/alire.toml");
      Need_File ("config_runtime/alire.toml");
      Need_File ("config_secrets/alire.toml");
      Need_File ("config_secrets/src/config_secrets.ads");
      Need_File ("tests/config_secrets_tests/alire.toml");
      Need_File ("examples/config_examples/alire.toml");
      Need_File ("examples/config_examples/src/quickstart.adb");
      Need_File ("invariant-registry/mapping.md");
      Need_File ("docs/INTEGRATION.md");
      Need_File ("docs/ACCEPTANCE.md");
      Need_File ("docs/QUICKSTART.md");
      Need_File ("docs/ARCHITECTURE.md");
      Need_File ("docs/RELEASE.md");
      Need_File ("docs/PHASE_STATUS.md");
      Need_File ("docs/ai/invariants.md");
      Need_File ("docs/ai/package_map.md");
      Need_File ("docs/ai/prohibited_patterns.md");
      Need_File ("docs/ai/allowed_dependencies.md");
      Need_File ("docs/adr/README.md");

      Need_Text ("alire.toml", "gnat_native = ""=15.2.1""");
      Need_Text ("README.md", "config");
      Need_Text ("docs/ai/invariants.md", "CFG-INV-001");
      Need_Text ("invariant-registry/mapping.md", "CFG-INV-010");
   end Check_Surface;

   --  Dependency-boundary audit: the core may use the Ada stdlib and
   --  `representation` only. Environment, file, transport, and persistence
   --  packages are forbidden — that I/O lives in config_runtime.
   procedure Check_File (Full : String; Name : String) is
      procedure Forbid (Pkg : String) is
      begin
         if Files.File_Contains (Full, "with " & Pkg) then
            Fail (Name & ": forbidden dependency 'with " & Pkg & "'");
         end if;
      end Forbid;
   begin
      Forbid ("Web");
      Forbid ("Webframework");
      Forbid ("Authorization");
      Forbid ("Identity");
      Forbid ("Database");
      Forbid ("Tables");
      Forbid ("Forms");
      Forbid ("Jobs");
      Forbid ("Notifications");
      Forbid ("Logging");
      Forbid ("Templates");
      Forbid ("I18n");
      Forbid ("Messages");
      Forbid ("Httpclient");
      Forbid ("Smtplib");
      Forbid ("Cryptolib");
      Forbid ("GNAT.Sockets");
      Forbid ("GNAT.OS_Lib");
      Forbid ("Ada.Environment_Variables");
      Forbid ("Ada.Text_IO");
      Forbid ("Ada.Directories");
      Forbid ("Ada.Calendar");
      Forbid ("Ada.Streams.Stream_IO");
   end Check_File;

   procedure Check_Dependency_Boundary is
      Search : Ada.Directories.Search_Type;
      Item   : Ada.Directories.Directory_Entry_Type;
      Src    : constant String := The_Root & "/src";
   begin
      Ada.Directories.Start_Search
        (Search, Src, "*.ad*",
         Filter => [Ada.Directories.Ordinary_File => True, others => False]);
      while Ada.Directories.More_Entries (Search) loop
         Ada.Directories.Get_Next_Entry (Search, Item);
         Check_File
           (Ada.Directories.Full_Name (Item),
            Ada.Directories.Simple_Name (Item));
      end loop;
      Ada.Directories.End_Search (Search);
   end Check_Dependency_Boundary;

   procedure Check_Build_And_Test is
      Alr : constant String := Proc.Locate_Command ("alr");

      Tests_Dir : constant String := The_Root & "/tests/config_tests";
      Rt_Dir    : constant String := The_Root & "/config_runtime";
      Rt_Tests  : constant String :=
        Rt_Dir & "/tests/config_runtime_tests";
      Sec_Dir   : constant String := The_Root & "/config_secrets";
      Sec_Tests : constant String := The_Root & "/tests/config_secrets_tests";
      Ex_Dir    : constant String := The_Root & "/examples/config_examples";
      No_Args   : constant GNAT.OS_Lib.Argument_List := [];
   begin
      if not Run ("build library", The_Root, Alr,
                  [new String'("--non-interactive"), new String'("build")])
      then
         return;
      end if;
      if Run ("build tests", Tests_Dir, Alr,
              [new String'("--non-interactive"), new String'("build")])
      then
         Ignored := Run ("run tests", Tests_Dir, Tests_Dir & "/bin/tests", No_Args);
      end if;
      if Run ("build runtime", Rt_Dir, Alr,
              [new String'("--non-interactive"), new String'("build")])
        and then Run ("build runtime tests", Rt_Tests, Alr,
                      [new String'("--non-interactive"), new String'("build")])
      then
         Ignored :=
           Run ("run runtime tests", Rt_Tests, Rt_Tests & "/bin/tests", No_Args);
      end if;
      if Run ("build secrets bridge", Sec_Dir, Alr,
              [new String'("--non-interactive"), new String'("build")])
        and then Run ("build secrets bridge tests", Sec_Tests, Alr,
                      [new String'("--non-interactive"), new String'("build")])
      then
         Ignored :=
           Run ("run secrets bridge tests", Sec_Tests, Sec_Tests & "/bin/tests",
                No_Args);
      end if;
      if Run ("build example", Ex_Dir, Alr,
              [new String'("--non-interactive"), new String'("build")])
      then
         Ignored :=
           Run ("run example", Ex_Dir, Ex_Dir & "/bin/quickstart", No_Args);
      end if;
   end Check_Build_And_Test;

   procedure Check_Clean_Worktree (Label : String; Path : String) is
   begin
      RC.Require_Clean_Git_Worktree (Label => Label, Path => Path, Quiet => True);
   exception
      when Program_Error =>
         Fail (Label & " worktree must be clean for --release-strict");
   end Check_Clean_Worktree;

begin
   Check_Surface;
   Check_Dependency_Boundary;

   if Proc.Has_Argument ("--release")
     or else Proc.Has_Argument ("--release-strict")
   then
      Check_Build_And_Test;
   end if;

   if Proc.Has_Argument ("--release-strict") then
      Check_Clean_Worktree ("config", The_Root);
      Check_Clean_Worktree ("project_tools", The_Root & "/../project_tools");
   end if;

   if Errors = 0 then
      Put_Line ("check_config: all checks passed");
   else
      Put_Line
        (Standard_Error,
         "check_config:" & Natural'Image (Errors) & " error(s)");
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Check_Config;
