--  Config.Errors — the structured failure vocabulary. Invalid keys, capacity
--  exhaustion, parse errors, missing required values, and type mismatches are
--  reported as values, never exceptions (Rule 4.6). The top-level category is
--  reused from representation; the machine identifiers below are locale-neutral
--  and contract-stable — never localise or renumber them.
with Representation.Errors;
package Config.Errors
  with Preelaborate
is

   subtype Error_Category is Representation.Errors.Error_Category;

   Ok : Error_Category renames Representation.Errors.Ok;
   Syntax_Error : Error_Category renames Representation.Errors.Syntax_Error;
   Structural_Error : Error_Category
     renames Representation.Errors.Structural_Error;
   Representation_Constraint : Error_Category
     renames Representation.Errors.Representation_Constraint;
   Capacity_Failure : Error_Category
     renames Representation.Errors.Capacity_Failure;
   Internal_Error : Error_Category
     renames Representation.Errors.Internal_Error;

   --  Stable machine error identifiers (locale-neutral). Grouped by domain.
   Key_Invalid       : constant String := "config.key.invalid";
   Key_Too_Long      : constant String := "config.key.too-long";
   Duplicate_Key     : constant String := "config.key.duplicate";
   Value_Too_Long    : constant String := "config.value.too-long";
   Too_Many_Values   : constant String := "config.value.too-many";
   Too_Many_Entries  : constant String := "config.store.too-many-entries";
   Too_Many_Sources  : constant String := "config.source.too-many";
   Missing_Required  : constant String := "config.access.missing-required";
   Type_Mismatch     : constant String := "config.access.type-mismatch";
   Parse_Error       : constant String := "config.parse.error";

   subtype Sensitivity_Class is Representation.Errors.Sensitivity_Class;

end Config.Errors;
