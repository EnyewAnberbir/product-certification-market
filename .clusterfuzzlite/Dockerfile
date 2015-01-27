FROM gcr.io/oss-fuzz-base/base-builder
RUN apt-get update && apt-get install -y xz-utils
COPY . $SRC
RUN if [ -f "$SRC/third_party/zig-linux-x86_64-0.13.0.tar.xz" ]; then \
      tar -xJf "$SRC/third_party/zig-linux-x86_64-0.13.0.tar.xz" -C /usr/local && \
      ln -sf /usr/local/zig-linux-x86_64-0.13.0/zig /usr/local/bin/zig ; \
    else \
      apt-get install -y curl && \
      curl -fsSL https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz \
        | tar -xJ -C /usr/local && \
      ln -sf /usr/local/zig-linux-x86_64-0.13.0/zig /usr/local/bin/zig ; \
    fi
COPY .clusterfuzzlite/build.sh $SRC/build.sh
RUN chmod +x "$SRC/build.sh" "$SRC/.clusterfuzzlite/build.sh" || true
