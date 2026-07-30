--  Config.Keys — the dotted-key grammar. A key is a path of one or more
--  segments separated by '.', e.g. "server.http.port". Each segment is
--  non-empty ASCII of letters, digits, '_' and '-'; the whole key is bounded in
--  length (Key_Length) and depth (Segment_Count). Nested structures (TOML
--  tables, JSON objects) flatten to these keys. Keys are case-sensitive; source
--  adapters normalise (e.g. env `SERVER_PORT` -> `server.port`).
package Config.Keys
  with Pure
is

   Separator : constant Character := '.';

   --  Longest a single segment may be.
   Max_Segment_Length : constant := 128;

   --  Whether S is a well-formed dotted key: non-empty, within Key_Length, no
   --  leading/trailing/double separator, each segment non-empty and within
   --  Max_Segment_Length, every character in [A-Za-z0-9_-], and no more than
   --  Segment_Count'Last segments.
   --  @param S Candidate key.
   --  @return True when S is a valid key.
   function Is_Valid_Key (S : String) return Boolean;

   --  Number of dotted segments in S, or 0 when S is not a valid key.
   --  @param S A key.
   --  @return The segment count (dotted-key depth).
   function Depth (S : String) return Natural;

   --  The Index'th segment of a valid key (1-based).
   --  @param S A valid key.
   --  @param Index Segment position.
   --  @return The segment text.
   function Segment (S : String; Index : Positive) return String
     with Pre => Is_Valid_Key (S) and then Index <= Depth (S);

end Config.Keys;
