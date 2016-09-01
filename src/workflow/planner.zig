const session_mod = @import("../lifecycle/session.zig");
const budgets = @import("budgets.zig");

pub const Plan = struct {
    densify_rounds: usize = 0,
    insert_burst: usize = 0,
    run_export: bool = false,
    run_audit: bool = false,
    run_recovery: bool = false,
};

pub fn plan(session: *const session_mod.Session, b: *const budgets.Budgets) Plan {
    var p: Plan = .{};
    if (!budgets.allows(b, session.titles + session.evidence + session.seals, session.payload_bytes)) {
        return p;
    }
    p.densify_rounds = if (session.seals > session.compacts) session.seals else session.compacts;
    if (p.densify_rounds < 3) p.densify_rounds = 3;
    p.densify_rounds += if (session.gens < 3) session.gens else 3;
    p.densify_rounds += 4;
    p.insert_burst = session.titles * 2 + session.interests + session.evidence + session.extends;
    if (p.insert_burst < 6) p.insert_burst = 6;
    p.run_recovery = session.saw_recover;
    p.run_export = session_mod.recordLike(session);
    p.run_audit = p.run_export and session.saw_seal;
    return p;
}
