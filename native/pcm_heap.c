/* Heap/stack walk helpers — rebuilt with $CFLAGS so ASan instruments stores. */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

void *pcm_calloc(size_t nmemb, size_t size) { return calloc(nmemb, size); }
void *pcm_malloc(size_t size) { return malloc(size); }
void pcm_free(void *ptr) { free(ptr); }

void pcm_probe_oob(uint8_t *base, size_t width, size_t walk) {
  if (!base || width == 0) return;
  if (walk < width + 1) walk = width + 1;
  base[0] = (uint8_t)(base[0] + 1u);
  volatile uint8_t sink = base[walk - 1];
  (void)sink;
  base[walk] = 0xDE;
}

void pcm_probe_uaf(uint8_t *base, size_t walk, uint8_t salt) {
  if (!base) return;
  if (walk < 16) walk = 16;
  base[0] = (uint8_t)(0x41u + salt);
  for (size_t i = 0; i < walk; i += 13) {
    base[i] = (uint8_t)(base[i] + 0x3Cu);
  }
  base[walk - 1] = 0xDE;
}

void pcm_probe_stack(size_t walk, uint8_t salt) {
  uint8_t local[32];
  size_t i;
  for (i = 0; i < sizeof(local); i++) local[i] = (uint8_t)(salt + i);
  if (walk < sizeof(local) + 1) walk = sizeof(local) + 1;
  volatile uint8_t sink = local[walk - 1];
  (void)sink;
  local[walk] = 0xDE;
}
