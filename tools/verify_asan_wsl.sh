#!/usr/bin/env bash
set -euo pipefail
ROOT=/mnt/c/Users/0000w/OneDrive/Documents/New_Fenrir
REPO=$ROOT/product-certification-zig-work
POC=$ROOT/POC/product-certification-market
ZIG=/tmp/zig-0.13.0/zig
LIB=$REPO/zig-out/lib/libpcm.a
if [[ ! -x "$ZIG" ]]; then
  mkdir -p /tmp/zig-extract
  tar -xJf "$REPO/third_party/zig-linux-x86_64-0.13.0.tar.xz" -C /tmp/zig-extract
  rm -rf /tmp/zig-0.13.0
  mv /tmp/zig-extract/zig-linux-x86_64-0.13.0 /tmp/zig-0.13.0
fi
cd "$REPO"
rm -rf .zig-cache zig-cache zig-out
"$ZIG" build -Doptimize=Debug
test -f "$LIB"
clang -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -std=c11 \
  -c "$REPO/native/pcm_heap.c" -o /tmp/pcm_heap_asan.o
ar d "$LIB" pcm_heap.o 2>/dev/null || true
ar rcs "$LIB" /tmp/pcm_heap_asan.o
cat > /tmp/pcm_asan_runner.c <<'EOF'
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
void __zig_probe_stack(void) {}
typedef struct {
  uint64_t sections;
  uint64_t titles;
  uint64_t seals;
  uint64_t payload_bytes;
  uint64_t digest;
} pcm_workflow_stats_t;
pcm_workflow_stats_t pcm_process_bytes(const uint8_t *data, size_t size);
int main(int argc, char **argv) {
  if (argc < 2) return 2;
  FILE *f = fopen(argv[1], "rb");
  if (!f) return 3;
  fseek(f, 0, SEEK_END);
  long n = ftell(f);
  fseek(f, 0, SEEK_SET);
  if (n < 0 || n > 400000) return 4;
  uint8_t *buf = (uint8_t *)malloc((size_t)n);
  if (!buf) return 5;
  if (fread(buf, 1, (size_t)n, f) != (size_t)n) { free(buf); return 6; }
  fclose(f);
  pcm_workflow_stats_t s = pcm_process_bytes(buf, (size_t)n);
  printf("digest=%llx sections=%llu\n",
         (unsigned long long)s.digest,
         (unsigned long long)s.sections);
  free(buf);
  return 0;
}
EOF
clang -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer \
  /tmp/pcm_asan_runner.c "$LIB" -o /tmp/pcm_asan_runner -lpthread -ldl -lm
echo runner_built
export ASAN_OPTIONS=detect_leaks=0:halt_on_error=1
ok=0; miss=0; hbo=0; uaf=0; stack=0
for p in "$POC"/PCMK-*.bin; do
  set +e; out=$(/tmp/pcm_asan_runner "$p" 2>&1); set -e
  name=$(basename "$p")
  if echo "$out" | grep -q heap-buffer-overflow; then echo OK_HBO $name; ok=$((ok+1)); hbo=$((hbo+1))
  elif echo "$out" | grep -q heap-use-after-free; then echo OK_UAF $name; ok=$((ok+1)); uaf=$((uaf+1))
  elif echo "$out" | grep -q stack-buffer-overflow; then echo OK_STACK $name; ok=$((ok+1)); stack=$((stack+1))
  elif echo "$out" | grep -Eq 'AddressSanitizer|UndefinedBehaviorSanitizer'; then echo OK_ASAN $name; ok=$((ok+1))
  else echo MISS $name; echo "$out" | tail -15; miss=$((miss+1)); fi
done
echo CURATED ok=$ok miss=$miss hbo=$hbo uaf=$uaf stack=$stack
test $miss -eq 0
seed_bad=0
for p in "$REPO"/fuzz/corpus/pcm_fuzzer/*; do
  [[ -f "$p" ]] || continue
  set +e; out=$(/tmp/pcm_asan_runner "$p" 2>&1); set -e
  if echo "$out" | grep -Eq 'AddressSanitizer|UndefinedBehaviorSanitizer'; then echo SEED_CRASH $(basename "$p"); seed_bad=$((seed_bad+1)); fi
done
echo SEED_CLEAN_BAD=$seed_bad
test $seed_bad -eq 0
echo ALL_OK
