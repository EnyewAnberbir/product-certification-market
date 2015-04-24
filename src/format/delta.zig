const checksum = @import("checksum.zig");

/// Zigzag varint deltas for compact key streams in export / query plans.
pub fn encodeDelta(dst: []u8, prev: u32, next: u32) usize {
    const d: i64 = @as(i64, next) - @as(i64, prev);
    const zigzag: u32 = @truncate(@as(u64, @bitCast((d << 1) ^ (d >> 63))));
    if (dst.len < 5) return 0;
    var v = zigzag;
    var i: usize = 0;
    while (true) {
        if (v < 0x80) {
            dst[i] = @truncate(v);
            return i + 1;
        }
        dst[i] = @truncate((v & 0x7f) | 0x80);
        v >>= 7;
        i += 1;
        if (i >= dst.len) return 0;
    }
}

pub fn decodeDelta(src: []const u8, prev: u32, out: *u32) ?usize {
    var result: u32 = 0;
    var shift: u5 = 0;
    var i: usize = 0;
    while (i < src.len and i < 5) : (i += 1) {
        const b = src[i];
        result |= @as(u32, b & 0x7f) << shift;
        if ((b & 0x80) == 0) {
            const s: i32 = @bitCast(result >> 1);
            const delta: i32 = if ((result & 1) != 0) ~s else s;
            out.* = @truncate(@as(i64, prev) + delta);
            return i + 1;
        }
        shift += 7;
    }
    return null;
}

pub fn compressKeys(keys: []const u32, dst: []u8) usize {
    if (keys.len == 0) return 0;
    var prev: u32 = 0;
    var off: usize = 0;
    for (keys) |k| {
        if (off >= dst.len) break;
        const n = encodeDelta(dst[off..], prev, k);
        if (n == 0) break;
        off += n;
        prev = k;
    }
    return off;
}

pub fn expandKeys(src: []const u8, dst: []u32) usize {
    var prev: u32 = 0;
    var off: usize = 0;
    var n: usize = 0;
    while (off < src.len and n < dst.len) {
        var next: u32 = 0;
        const step = decodeDelta(src[off..], prev, &next) orelse break;
        dst[n] = next;
        n += 1;
        prev = next;
        off += step;
    }
    return n;
}

pub fn digestKeys(keys: []const u32) u64 {
    var h: u64 = 0xde17a001;
    var prev: u32 = 0;
    for (keys) |k| {
        h = checksum.pairDigest(h, (@as(u64, k) << 16) ^ prev);
        prev = k;
    }
    return h;
}

pub fn roundtripOk(keys: []const u32) bool {
    var buf: [256]u8 = undefined;
    var out: [64]u32 = undefined;
    if (keys.len > out.len) return false;
    const written = compressKeys(keys, buf[0..]);
    if (written == 0 and keys.len != 0) return false;
    const got = expandKeys(buf[0..written], out[0..keys.len]);
    if (got != keys.len) return false;
    var i: usize = 0;
    while (i < keys.len) : (i += 1) {
        if (out[i] != keys[i]) return false;
    }
    return true;
}
