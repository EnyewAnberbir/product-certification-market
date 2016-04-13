const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const code = "RED";
pub const clause_count: u32 = 60;
pub const base_weight: u32 = 1200;

pub const Assessment = struct {
    applicable: bool = false,
    clauses_hit: u32 = 0,
    residual: u32 = 0,
    digest: u64 = 0,
};

pub fn assess(session: *const session_mod.Session) Assessment {
    var a: Assessment = .{};
    a.applicable = session.titles > 0 and (session.payload_bytes % (base_weight + 7)) > 3;
    if (!a.applicable) return a;
    a.clauses_hit = @truncate((session.evidence * 3 + session.seals * 2) % (clause_count + 1));
    a.residual = if (a.clauses_hit < clause_count) clause_count - a.clauses_hit else 0;
    var h = checksum.pairDigest(session.payload_bytes, base_weight);
    h ^= (@as(u64, a.clauses_hit) << 20) ^ a.residual;
    // Directive-specific folding so modules are not identical.
    var i: u32 = 0;
    while (i < a.clauses_hit and i < 32) : (i += 1) {
        h ^= (@as(u64, i + 1) *% base_weight) << @as(u6, @truncate((i * 3) % 17));
        h *%= 0x9e3779b97f4a7c15;
        h ^= h >> 11;
    }
    if (session.recovers > 0) h ^= 0x65fb;
    a.digest = h;
    return a;
}

pub fn blocksCertificate(a: *const Assessment) bool {
    return a.applicable and a.residual > clause_count / 3;
}

pub fn surveillanceBoost(a: *const Assessment) u32 {
    if (!a.applicable) return 0;
    return a.residual / 4 + (if (a.clauses_hit < 3) @as(u32, 2) else 0);
}
