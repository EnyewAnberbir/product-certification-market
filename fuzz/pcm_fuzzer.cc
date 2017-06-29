#include "pcm/api.h"
#include <cstddef>
#include <cstdint>
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  if (size > 400000) return 0;
  pcm_workflow_stats_t r = pcm_process_bytes(data, size);
  volatile uint64_t sink = r.digest ^ r.sections ^ r.payload_bytes;
  (void)sink;
  return 0;
}
