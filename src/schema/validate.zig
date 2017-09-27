const types = @import("types.zig");
const registry = @import("registry.zig");
const session_mod = @import("../lifecycle/session.zig");

pub const SchemaReport = struct {
    ok: bool = false,
    epoch: u16 = 0,
    missing_required: u32 = 0,
    digest: u64 = 0,
};

pub fn validateSession(session: *const session_mod.Session) SchemaReport {
    var r: SchemaReport = .{};
    const epoch = registry.builtinEpoch(session);
    r.epoch = epoch.version;
    const mask = registry.requiredMask(epoch);
    // Map session counters onto required field presence.
    var present: u64 = 0;
    if (session.titles > 0) present |= 1;
    if (session.interests > 0) present |= 2;
    if (session.evidence > 0) present |= 4;
    if (session.parties > 0) present |= 8;
    if (session.seals > 0) present |= 16;
    const missing = mask & ~present;
    r.missing_required = @popCount(missing);
    r.ok = r.missing_required == 0 and session_mod.recordLike(session);
    r.digest = epoch.digest ^ present ^ r.missing_required;
    return r;
}
