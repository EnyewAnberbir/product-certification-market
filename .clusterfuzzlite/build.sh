#!/bin/bash -eu
set -o pipefail
: "${SRC:?}"
: "${OUT:?}"
: "${CXX:?}"
: "${WORK:?}"
cd "$SRC"

resolve_zig() {
  if [[ -n "${ZIG:-}" && "${ZIG}" == /* && -x "${ZIG}" ]]; then
    echo "${ZIG}"
    return 0
  fi
  local extract="$WORK/zig-toolchain"
  local zig_bin="$extract/zig-linux-x86_64-0.13.0/zig"
  if [[ -x "$zig_bin" ]]; then
    echo "$zig_bin"
    return 0
  fi
  local archive="$SRC/third_party/zig-linux-x86_64-0.13.0.tar.xz"
  if [[ -f "$archive" ]]; then
    mkdir -p "$extract"
    tar -xJf "$archive" -C "$extract"
    if [[ -x "$zig_bin" ]]; then
      echo "$zig_bin"
      return 0
    fi
  fi
  if command -v zig >/dev/null 2>&1; then
    command -v zig
    return 0
  fi
  if [[ -x /usr/local/bin/zig ]]; then
    echo /usr/local/bin/zig
    return 0
  fi
  if [[ -x /usr/local/zig-linux-x86_64-0.13.0/zig ]]; then
    echo /usr/local/zig-linux-x86_64-0.13.0/zig
    return 0
  fi
  echo "error: zig not found; expected PATH, /usr/local, or $archive" >&2
  return 127
}

ZIG="$(resolve_zig)"
export ZIG_GLOBAL_CACHE_DIR="${ZIG_GLOBAL_CACHE_DIR:-$WORK/zig-global-cache}"
export ZIG_LOCAL_CACHE_DIR="${ZIG_LOCAL_CACHE_DIR:-$WORK/zig-local-cache}"
mkdir -p "$WORK/pcm" "$OUT" "$WORK/objs" \
  "$ZIG_GLOBAL_CACHE_DIR" "$ZIG_LOCAL_CACHE_DIR"
"$ZIG" version
"$ZIG" build -Doptimize=Debug --prefix "$WORK/pcm"
LIB="$WORK/pcm/lib/libpcm.a"
if [[ ! -f "$LIB" ]]; then
  LIB="$(find "$WORK/pcm" -name 'libpcm.a' | head -n1)"
fi
if [[ ! -f "$LIB" ]]; then
  echo "error: libpcm.a not produced under $WORK/pcm" >&2
  exit 1
fi

# Rebuild heap helpers with sanitizer flags from the fuzzing environment.
"${CC:-clang}" ${CFLAGS:-} -std=c11 -c "$SRC/native/pcm_heap.c" -o "$WORK/objs/pcm_heap.o"
ar d "$LIB" pcm_heap.o 2>/dev/null || true
ar rcs "$LIB" "$WORK/objs/pcm_heap.o"

cat > "$WORK/zig_rt_stub.c" <<'STUB'
void __zig_probe_stack(void) {}
STUB
"${CC:-clang}" ${CFLAGS:-} -c "$WORK/zig_rt_stub.c" -o "$WORK/zig_rt_stub.o"

"$CXX" $CXXFLAGS -std=c++17 -I"$SRC/include" \
  "$SRC/fuzz/pcm_fuzzer.cc" "$LIB" "$WORK/zig_rt_stub.o" $LIB_FUZZING_ENGINE \
  -o "$OUT/pcm_fuzzer"
if [[ -f "$SRC/fuzz/dictionary.txt" ]]; then
  cp "$SRC/fuzz/dictionary.txt" "$OUT/pcm_fuzzer.dict"
fi
if [[ -d "$SRC/fuzz/corpus/pcm_fuzzer" ]]; then
  ( cd "$SRC/fuzz/corpus/pcm_fuzzer" && zip -qr "$OUT/pcm_fuzzer_seed_corpus.zip" . ) || true
fi
