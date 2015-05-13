const decisions = @import("decisions.zig");
const session_mod = @import("../lifecycle/session.zig");

pub const AppealCase = struct {
    filed: bool = false,
    overturned: bool = false,
    digest: u64 = 0,
};

pub fn consider(session: *const session_mod.Session, dec: *const decisions.DecisionReport) AppealCase {
    var a: AppealCase = .{};
    a.filed = dec.outcome == .rejected and session.queries > 0;
    if (a.filed) {
        a.overturned = session.evidence > dec.votes_against and session.seals > 0;
    }
    a.digest = (@as(u64, @intFromEnum(dec.outcome)) << 24) ^ (if (a.overturned) @as(u64, 2) else 0) ^ dec.digest;
    return a;
}
