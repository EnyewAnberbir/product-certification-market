const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const ChainLink = struct {
    seq: u32 = 0,
    evidence_hash: u64 = 0,
    sealed: bool = false,
};

pub const ChainReport = struct {
    links: u32 = 0,
    broken: bool = false,
    digest: u64 = 0,
};

pub fn build(session: *const session_mod.Session) ChainReport {
    var r: ChainReport = .{};
    const n = session.evidence;
    var prev: u64 = 0xC0CAC01A;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const h = checksum.pairDigest(prev, session.payload_bytes ^ i);
        prev = h;
        r.links += 1;
        r.digest ^= h << @as(u6, @truncate(i % 17));
    }
    r.broken = session.queries > 0 and session.evidence == 0;
    if (session.saw_seal and r.links > 0) r.digest ^= 1;
    return r;
}

pub fn requiredForDecision(r: *const ChainReport) bool {
    return !r.broken and r.links > 0;
}
