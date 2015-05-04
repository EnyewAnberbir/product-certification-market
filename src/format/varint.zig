pub fn encodeU64(buf: []u8, value: u64) usize {
    var v = value;
    var i: usize = 0;
    while (true) {
        if (i >= buf.len) return 0;
        if (v < 0x80) {
            buf[i] = @truncate(v);
            return i + 1;
        }
        buf[i] = @truncate((v & 0x7f) | 0x80);
        v >>= 7;
        i += 1;
    }
}

pub fn decodeU64(data: []const u8, out: *u64) ?usize {
    var result: u64 = 0;
    var shift: u6 = 0;
    var i: usize = 0;
    while (i < data.len and i < 10) : (i += 1) {
        const b = data[i];
        result |= @as(u64, b & 0x7f) << shift;
        if ((b & 0x80) == 0) {
            out.* = result;
            return i + 1;
        }
        shift += 7;
    }
    return null;
}

pub fn encodeZigZag(buf: []u8, value: i64) usize {
    const u: u64 = @bitCast((value << 1) ^ (value >> 63));
    return encodeU64(buf, u);
}

pub fn decodeZigZag(data: []const u8, out: *i64) ?usize {
    var u: u64 = 0;
    const n = decodeU64(data, &u) orelse return null;
    const s: i64 = @bitCast(u >> 1);
    out.* = if ((u & 1) != 0) ~s else s;
    return n;
}

pub fn encodedLen(value: u64) usize {
    var v = value;
    var n: usize = 1;
    while (v >= 0x80) : (n += 1) v >>= 7;
    return n;
}
