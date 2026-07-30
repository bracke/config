package body Config.Store.Probe is

   function Pool_High_Water (S : Store) return Natural is (S.Pool_Top);

   function Pool_Byte (S : Store; I : Positive) return Natural is
     (Character'Pos (S.Chars (I)));

end Config.Store.Probe;
