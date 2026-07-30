--  config — a headless configuration library for Ada 2022. It loads settings
--  from layered sources (defaults, files, environment, explicit overrides) into
--  one bounded, typed store keyed by dotted paths, tracks where each value came
--  from (provenance), marks secrets for redaction, and offers typed access
--  (string / integer / float / boolean / datetime / arrays) with required-vs-
--  default and validation. The core reads no environment and opens no files:
--  every source is an injected seam; file/env I/O lives in `config_runtime`.
--  Scalar typing and JSON parsing reuse `representation`.
--
--  The root package is a small strong-scalar vocabulary (Rule 4.7); no
--  behaviour lives here.
package Config
  with Pure
is

   --  Public contract version. Bumped only on an incompatible surface change.
   API_Version : constant := 1;

   --  Bounded structural counts. A store is bounded in every dimension.
   type Entry_Count   is range 0 .. 2 ** 16;   --  distinct keys in a store
   type Value_Index   is range 0 .. 2 ** 12;   --  values under one key (arrays)
   type Source_Count  is range 0 .. 64;        --  layered sources
   type Segment_Count is range 0 .. 64;        --  dotted-key segments / depth

   --  Text sizes (keys, values, and parse input are text).
   type Key_Length   is range 0 .. 512;        --  a whole dotted key
   type Value_Length is range 0 .. 2 ** 16;    --  a single value's text
   type Byte_Count   is range 0 .. 2 ** 24;    --  a parse input's size

   Library_Name    : constant String := "config";
   Library_Version : constant String := "0.1.0-dev";

end Config;
