const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const tag = "EL";
const TABLE: [8]u32 = .{ 1, 4, 9, 16, 25, 36, 49, 64 };
const SALT: u32 = 129242;

pub const Report = struct {
    applicable: bool = false,
    index: u32 = 0,
    weighted: u64 = 0,
    digest: u64 = 0,
};

pub fn evaluate(session: *const session_mod.Session) Report {
    var r: Report = .{};
    r.applicable = session.titles > 0;
    if (!r.applicable) return r;
    r.index = @truncate(session.payload_bytes % TABLE.len);
    r.weighted = @as(u64, TABLE[r.index]) *% SALT;
    r.weighted +%= session.evidence * 3 + session.seals * 5;
    var h = checksum.pairDigest(r.weighted, session.payload_bytes ^ SALT);
    var i: usize = 0;
    while (i < TABLE.len) : (i += 1) {
        const v = TABLE[i];
        h ^= (@as(u64, v) << @as(u6, @truncate((i * 5 + 1) % 16)));
        h *%= 0x9e3779b97f4a7c15;
        if ((session.recovers > 0) and (i % 2 == 0)) h ^= v;
    }
    // Tag-specific trajectory so each module differs in control flow shape.
    if (session.queries > TABLE[0]) {
        h ^= (@as(u64, SALT) << 17) ^ session.queries;
    } else {
        h +%= TABLE[r.index % TABLE.len];
    }
    r.digest = h;
    return r;
}

pub fn thresholdOk(r: *const Report, min_weight: u64) bool {
    return r.applicable and r.weighted >= min_weight;
}

pub fn foldInto(acc: u64, r: *const Report) u64 {
    return checksum.pairDigest(acc, r.digest ^ (@as(u64, r.index) << 8));
}
