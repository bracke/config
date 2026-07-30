with AUnit.Test_Suites;

--  Aggregate suite for the logging library. Phase 0 wires only the foundation
--  smoke suite; later phases register levels/fields/events/loggers/sinks/
--  encoders/redaction/hardening suites here.
package All_Suites is

   --  Build the aggregate AUnit suite.
   --  @return The suite of all registered logging tests.
   function Suite return AUnit.Test_Suites.Access_Test_Suite;

end All_Suites;
