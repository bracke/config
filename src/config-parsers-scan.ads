--  Config.Parsers.Scan — shared lexical helpers for the line-oriented parsers:
--  whitespace trimming and value unquoting (bare, single-quoted literal, or
--  double-quoted with \n \t \r \" \\ escapes). Output is written into a
--  caller-provided buffer (unquoting never grows the input).
package Config.Parsers.Scan
  with Preelaborate
is

   --  S with leading and trailing spaces and tabs removed.
   function Trim (S : String) return String;

   --  Unquote an already-trimmed value. A double-quoted value has its escapes
   --  processed; a single-quoted value is taken literally; anything else is
   --  copied verbatim. Ok is False on an unterminated quote. Buffer must be at
   --  least S'Length long; Last is the number of characters written.
   procedure Unquote
     (S      : String;
      Buffer : out String;
      Last   : out Natural;
      Ok     : out Boolean);

end Config.Parsers.Scan;
