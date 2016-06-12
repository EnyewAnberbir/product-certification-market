const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const TechFile = struct {
    revisions: u32 = 0,
    pages: u32 = 0,
    hash: u64 = 0,
    replacement_of: u64 = 0,
};

pub fn build(session: *const session_mod.Session) TechFile {
    var t: TechFile = .{};
    t.revisions = @truncate(session.extends + 1);
    t.pages = @truncate(4 + session.evidence * 2 + session.titles);
    t.hash = checksum.pairDigest(session.payload_bytes, (@as(u64, t.revisions) << 32) ^ t.pages);
    t.replacement_of = if (session.recovers > 0) checksum.pairDigest(t.hash, session.recovers) else 0;
    return t;
}

pub fn stableAcrossSeal(a: *const TechFile, b: *const TechFile) bool {
    return a.hash == b.hash and a.revisions == b.revisions;
}

pub fn needsManualReview(t: *const TechFile) bool {
    return t.pages > 40 or (t.replacement_of != 0 and t.revisions < 2);
}

pub fn annexCount(t: *const TechFile, evidence: usize) u32 {
    const base = t.pages / 8;
    return base + @as(u32, @truncate(evidence % 5));
}
