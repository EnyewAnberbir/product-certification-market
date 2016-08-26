const runtime = @import("../projection/runtime.zig");
const session_mod = @import("../lifecycle/session.zig");

pub fn runDensify(session: *const session_mod.Session) void {
    var rebuild_rounds: usize = if (session.seals > session.compacts) session.seals else session.compacts;
    if (rebuild_rounds < 3) rebuild_rounds = 3;
    rebuild_rounds += if (session.gens < 3) session.gens else 3;
    rebuild_rounds += 4;
    var insert_burst: usize = session.titles * 2 + session.interests + session.evidence + session.extends;
    if (insert_burst < 6) insert_burst = 6;
    var round: usize = 0;
    while (round < rebuild_rounds) : (round += 1) {
        runtime.rebuildAll(round, insert_burst);
        if (session.cancel_armed) runtime.cancelAll(round);
    }
}

pub fn runLateObservers() void {
    runtime.reconcileDerivedIndexes();
    runtime.runMaterializePipeline();
    runtime.runRecoveryPipeline();
    runtime.runExportPipeline();
    runtime.runAuditPipeline();
}
