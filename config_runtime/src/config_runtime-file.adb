with Ada.Directories;
with Ada.Streams;
with Ada.Streams.Stream_IO;

with Config.Parsers;

package body Config_Runtime.File is

   use type Config.Parsers.Parse_Status;
   use type Ada.Directories.File_Size;

   function Ends_With (S, Suffix : String) return Boolean is
     (S'Length >= Suffix'Length
      and then S (S'Last - Suffix'Length + 1 .. S'Last) = Suffix);

   procedure Detect_Format
     (Path : String; Fmt : out Config.Formats.Format; Ok : out Boolean) is
   begin
      Ok := True;
      if Ends_With (Path, ".toml") then
         Fmt := Config.Formats.Toml;
      elsif Ends_With (Path, ".json") then
         Fmt := Config.Formats.Json;
      elsif Ends_With (Path, ".ini") or else Ends_With (Path, ".cfg")
        or else Ends_With (Path, ".conf")
      then
         Fmt := Config.Formats.Ini;
      elsif Ends_With (Path, ".env") then
         Fmt := Config.Formats.Dotenv;
      else
         Fmt := Config.Formats.Toml;
         Ok := False;
      end if;
   end Detect_Format;

   overriding procedure Load
     (Self : in out Source;
      Into : in out Config.Store.Store;
      Id   : Config.Store.Source_Id;
      Ok   : out Boolean)
   is
      Path : constant String := Self.Path.all;
   begin
      if not Ada.Directories.Exists (Path) then
         Ok := Self.Optional;
         return;
      end if;

      declare
         Size : constant Ada.Directories.File_Size := Ada.Directories.Size (Path);
      begin
         if Size > Ada.Directories.File_Size (Max_File_Bytes) then
            Ok := False;
            return;
         end if;

         declare
            Fmt     : Config.Formats.Format;
            Det_Ok  : Boolean := True;
            N       : constant Natural := Natural (Size);
            Buf     : String (1 .. N);
            F       : Ada.Streams.Stream_IO.File_Type;
            SEA     : Ada.Streams.Stream_Element_Array
                        (1 .. Ada.Streams.Stream_Element_Offset (N));
            Last    : Ada.Streams.Stream_Element_Offset;
            PR      : Config.Parsers.Parse_Result;
         begin
            if Self.Detect then
               Detect_Format (Path, Fmt, Det_Ok);
            else
               Fmt := Self.Format;
            end if;
            if not Det_Ok then
               Ok := False;
               return;
            end if;

            Ada.Streams.Stream_IO.Open
              (F, Ada.Streams.Stream_IO.In_File, Path);
            Ada.Streams.Stream_IO.Read (F, SEA, Last);
            Ada.Streams.Stream_IO.Close (F);

            for I in 1 .. Natural (Last) loop
               Buf (I) := Character'Val (Integer (SEA (Ada.Streams.Stream_Element_Offset (I))));
            end loop;

            Config.Formats.Parse
              (Fmt, Buf (1 .. Natural (Last)), Into, Id, PR);
            Ok := PR.Status = Config.Parsers.Parsed;
         end;
      end;
   exception
      when others =>
         Ok := False;
   end Load;

end Config_Runtime.File;
