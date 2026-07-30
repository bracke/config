--  Test-only child of Config.Store: reads into the private char pool so a test
--  can observe that Clear/Finalize actually zeroes secret material. Lives in the
--  test crate, not the library.
package Config.Store.Probe is

   --  The used-pool high-water mark (bytes written to the char pool).
   function Pool_High_Water (S : Store) return Natural;

   --  The byte value at pool position I (1 .. Pool).
   function Pool_Byte (S : Store; I : Positive) return Natural;

end Config.Store.Probe;
