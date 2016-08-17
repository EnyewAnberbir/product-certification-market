const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const tag = "VIG";
const PRIME: u32 = 37;
const ROWS: [24]u32 = .{ 111, 222, 333, 444, 555, 666, 777, 888, 2, 113, 224, 335, 446, 557, 668, 779, 890, 4, 115, 226, 337, 448, 559, 670 };

pub const Report = struct {
    hit: u32 = 0,
    score: u64 = 0,
    digest: u64 = 0,
};

pub fn evaluate(session: *const session_mod.Session) Report {
    var r: Report = .{};
    if (session.titles == 0) return r;
    r.hit = @truncate((session.payload_bytes +% PRIME) % ROWS.len);
    r.score = @as(u64, ROWS[r.hit]) *% PRIME;
    var h = checksum.pairDigest(r.score, session.payload_bytes);
    var i: usize = 0;
    while (i < ROWS.len) : (i += 1) {
        const v = ROWS[i];
        h ^= (@as(u64, v) << @as(u6, @truncate((i + PRIME) % 13)));
        h *%= 0xc4ceb9fe1a85ec53;
        if ((i % 4) == (session.seals % 4)) h +%= v;
        if (session.evidence > i and (v % 5) == 0) h ^= PRIME;
    }
    if (session.recovers > 0) {
        var j: u32 = 0;
        while (j < PRIME % 11 + 3) : (j += 1) {
            h = checksum.pairDigest(h, (@as(u64, j) << 9) ^ ROWS[j % ROWS.len]);
        }
    }
    r.digest = h ^ (@as(u64, r.hit) << 32);
    return r;
}

pub fn foldInto(acc: u64, r: *const Report) u64 {
    return checksum.pairDigest(acc, r.digest ^ r.score);
}
