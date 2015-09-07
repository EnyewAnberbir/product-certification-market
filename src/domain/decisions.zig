const session_mod = @import("../lifecycle/session.zig");
const evidence = @import("evidence.zig");
const standards = @import("standards.zig");
const cert_math = @import("cert_math.zig");

pub const DecisionOutcome = enum(u8) {
    pending = 0,
    approved = 1,
    rejected = 2,
    deferred = 3,
};

pub const DecisionReport = struct {
    outcome: DecisionOutcome = .pending,
    votes_for: u32 = 0,
    votes_against: u32 = 0,
    quorum: u32 = 0,
    digest: u64 = 0,
};

pub fn evaluate(
    session: *const session_mod.Session,
    stds: *const standards.StandardView,
    ev: *const evidence.EvidenceReport,
) DecisionReport {
    var d: DecisionReport = .{};
    d.quorum = 2 + @as(u32, @truncate(session.parties % 3));
    d.votes_for = @as(u32, @truncate(ev.accepted));
    d.votes_against = @as(u32, @truncate(ev.rejected + ev.conflicts));
    if (standards.blocksDecision(stds) or evidence.blocksDecision(ev)) {
        d.outcome = .deferred;
    } else if (cert_math.quorumMet(d.votes_for, d.votes_against, d.quorum)) {
        d.outcome = .approved;
    } else if (d.votes_against >= d.quorum) {
        d.outcome = .rejected;
    } else {
        d.outcome = .pending;
    }
    d.digest = session.payload_bytes ^ (@as(u64, @intFromEnum(d.outcome)) << 32) ^ d.votes_for ^ d.votes_against;
    return d;
}
