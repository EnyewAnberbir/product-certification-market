# Product Certification Market (Zig)

Offline conformity-assessment package engine for scheme records, standards,
laboratory evidence, certification decisions, certificates/marks, factory
surveillance, complaints/CAPA, recalls, and public mark verification.

This is a library and CLI — not only a fuzz target.

## Build

```bash
zig build
zig build test
./zig-out/bin/pcm validate fuzz/corpus/pcm_fuzzer/seed_01.bin
./zig-out/bin/pcm inspect fuzz/corpus/pcm_fuzzer/seed_01.bin
./zig-out/bin/pcm evaluate fuzz/corpus/pcm_fuzzer/seed_01.bin
./zig-out/bin/pcm process fuzz/corpus/pcm_fuzzer/seed_01.bin
```

## Library API

```c
#include "pcm/api.h"

pcm_validate_result_t v = pcm_validate_bytes(buf, n);
pcm_inspect_result_t i = pcm_inspect_bytes(buf, n);
pcm_engine_report_t e = pcm_evaluate_bytes(buf, n);
pcm_workflow_stats_t w = pcm_process_bytes(buf, n);
pcm_workflow_stats_t r = pcm_recover_bytes(buf, n);
pcm_export_result_t x = pcm_export_bytes(buf, n, out, out_cap);
uint64_t ok = pcm_verify_mark(buf, n, mark_prefix, model_units);
```

## Package format

Little-endian `PCMK` containers with typed scheme/standard/evidence/decision
records, recovery journals, and export tickets. Domain engines resolve
effective standards, evidence acceptance, decisions, certificate scope, and
surveillance obligations before late export/audit observers run.

## Fuzzing

ClusterFuzzLite target: `pcm_fuzzer` (harness calls `pcm_process_bytes`).
