const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

/// Rolling market-surveillance signal from complaint / recall pressure.
pub const Series = struct {
    len: usize = 0,
    points: [64]i16 = [_]i16{0} ** 64,
    mean: i32 = 0,
    peak: i16 = 0,
    digest: u64 = 0,
};

pub fn sample(session: *const session_mod.Session) Series {
    var s: Series = .{};
    s.len = @min(8 + session.evidence + session.parties, s.points.len);
    var sum: i32 = 0;
    var peak: i16 = -32768;
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        const base: i32 = @as(i32, @intCast((session.payload_bytes + i * 13) % 100)) - 40;
        const shock: i32 = if ((session.recovers > 0) and (i % 5 == 0)) 25 else 0;
        const seal_boost: i32 = if (session.seals > i) 3 else -1;
        var v: i32 = base + shock + seal_boost;
        if (v > 127) v = 127;
        if (v < -128) v = -128;
        const iv: i16 = @intCast(v);
        s.points[i] = iv;
        sum += iv;
        if (iv > peak) peak = iv;
    }
    s.mean = if (s.len == 0) 0 else @divTrunc(sum, @as(i32, @intCast(s.len)));
    s.peak = peak;
    var h: u64 = 0x51520100;
    i = 0;
    while (i < s.len) : (i += 1) {
        h = checksum.pairDigest(h, @as(u64, @bitCast(@as(i64, s.points[i]))));
    }
    s.digest = h ^ @as(u64, @bitCast(@as(i64, s.mean))) ^ (@as(u64, @bitCast(@as(i64, s.peak))) << 16);
    return s;
}

pub fn volatility(s: *const Series) u32 {
    if (s.len < 2) return 0;
    var acc: u32 = 0;
    var i: usize = 1;
    while (i < s.len) : (i += 1) {
        const d = @abs(@as(i32, s.points[i]) - @as(i32, s.points[i - 1]));
        acc += @intCast(d);
    }
    return acc;
}

pub fn alert(s: *const Series) bool {
    return s.peak >= 40 or (s.mean >= 15 and volatility(s) > 80);
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    const s = sample(session);
    var h = checksum.pairDigest(acc, s.digest);
    h ^= volatility(&s);
    if (alert(&s)) h ^= 0xa1e77001;
    return h;
}
