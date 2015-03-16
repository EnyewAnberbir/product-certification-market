const container = @import("container.zig");
const checksum = @import("checksum.zig");

pub const CanonicalReport = struct {
    bytes: usize = 0,
    digest: u64 = 0,
    stable: bool = false,
};

pub fn measure(env: *const container.Envelope) CanonicalReport {
    var r: CanonicalReport = .{};
    r.bytes = 10;
    var i: usize = 0;
    var parts: [64]u64 = [_]u64{0} ** 64;
    var pc: usize = 0;
    while (i < env.record_count) : (i += 1) {
        const rec = env.records[i];
        r.bytes += 14 + rec.payload_len;
        if (pc < parts.len) {
            const payload = if (rec.payload) |p| p[0..rec.payload_len] else &[_]u8{};
            parts[pc] = checksum.sectionDigest(@intFromEnum(rec.op), rec.key, payload);
            pc += 1;
        }
    }
    r.digest = checksum.combineMany(parts[0..pc]);
    r.stable = env.record_count > 0 and r.bytes >= 10;
    return r;
}

pub fn orderKey(op: container.Op, key: u32, aux: u32) u64 {
    return (@as(u64, @intFromEnum(op)) << 48) ^ (@as(u64, key) << 16) ^ aux;
}

pub fn recordsAreOrdered(env: *const container.Envelope) bool {
    if (env.record_count < 2) return true;
    var i: usize = 1;
    while (i < env.record_count) : (i += 1) {
        const prev = env.records[i - 1];
        const cur = env.records[i];
        if (orderKey(cur.op, cur.key, cur.aux) < orderKey(prev.op, prev.key, prev.aux)) return false;
    }
    return true;
}
