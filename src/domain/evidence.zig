const session_mod = @import("../lifecycle/session.zig");
const standards = @import("standards.zig");

pub const EvidenceReport = struct {
    accepted: usize = 0,
    rejected: usize = 0,
    conflicts: usize = 0,
    digest: u64 = 0,
};

/// Accept evidence only when lab-period style counters (parties) and accreditation
/// pressure (evidence records) align with at least one effective standard.
pub fn evaluate(session: *const session_mod.Session, stds: *const standards.StandardView) EvidenceReport {
    var r: EvidenceReport = .{};
    const lab_ok = session.parties > 0;
    const scope_ok = stds.effective > 0;
    var i: usize = 0;
    while (i < session.evidence) : (i += 1) {
        if (lab_ok and scope_ok) {
            r.accepted += 1;
        } else {
            r.rejected += 1;
        }
    }
    if (session.evidence >= 2 and session.queries > session.evidence) {
        r.conflicts = 1;
    }
    r.digest = (@as(u64, r.accepted) << 24) ^ (@as(u64, r.rejected) << 8) ^ r.conflicts ^ stds.digest;
    return r;
}

pub fn blocksDecision(r: *const EvidenceReport) bool {
    return r.conflicts > 0 or (r.accepted == 0 and r.rejected > 0);
}
