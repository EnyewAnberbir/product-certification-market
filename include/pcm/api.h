#ifndef PCM_API_H
#define PCM_API_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
  uint64_t sections;
  uint64_t titles;
  uint64_t seals;
  uint64_t payload_bytes;
  uint64_t digest;
} pcm_workflow_stats_t;

typedef struct {
  uint64_t ok;
  uint64_t record_count;
  uint64_t checksum;
  uint64_t error_code;
} pcm_validate_result_t;

typedef struct {
  uint64_t schemes;
  uint64_t standards;
  uint64_t evidence;
  uint64_t decisions;
  uint64_t seals;
  uint64_t recovers;
  uint64_t payload_bytes;
  uint64_t digest;
} pcm_inspect_result_t;

typedef struct {
  uint64_t standards_effective;
  uint64_t evidence_accepted;
  uint64_t decision;
  uint64_t certificate_active;
  uint64_t samples_due;
  uint64_t recall_armed;
  uint64_t verify_ok;
  uint64_t digest;
} pcm_engine_report_t;

typedef struct {
  uint64_t bytes_written;
  uint64_t digest;
  uint64_t error_code;
} pcm_export_result_t;

/* Full certification workflow used by the fuzz harness and CLI. */
pcm_workflow_stats_t pcm_process_bytes(const uint8_t *data, size_t size);

/* Parse + checksum validation without materialize/export side effects. */
pcm_validate_result_t pcm_validate_bytes(const uint8_t *data, size_t size);

/* Structural inspection of scheme/standard/evidence/decision counters. */
pcm_inspect_result_t pcm_inspect_bytes(const uint8_t *data, size_t size);

/* Domain engine: standards, evidence, decision, certificate, surveillance. */
pcm_engine_report_t pcm_evaluate_bytes(const uint8_t *data, size_t size);

/* Recovery-oriented re-process (journal replay path). */
pcm_workflow_stats_t pcm_recover_bytes(const uint8_t *data, size_t size);

/* Canonical re-export into caller buffer; returns bytes written. */
pcm_export_result_t pcm_export_bytes(const uint8_t *data, size_t size,
                                    uint8_t *out, size_t out_cap);

/* Public mark verification helper (model scope check). */
uint64_t pcm_verify_mark(const uint8_t *data, size_t size, uint32_t mark_prefix, uint32_t model_units);

#ifdef __cplusplus
}
#endif
#endif
