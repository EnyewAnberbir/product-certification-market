const session_mod = @import("../lifecycle/session.zig");
const standards = @import("standards.zig");

pub const ScopeCell = struct {
    standard_bits: u64 = 0,
    lab_id: u32 = 0,
    valid: bool = false,
};

pub const MapReport = struct {
    cells: u32 = 0,
    covered: u32 = 0,
    digest: u64 = 0,
};

pub fn build(session: *const session_mod.Session, stds: *const standards.StandardView) MapReport {
    var r: MapReport = .{};
    r.cells = @truncate(session.parties + stds.revisions);
    var i: u32 = 0;
    while (i < r.cells) : (i += 1) {
        const bit: u64 = @as(u64, 1) << @as(u6, @truncate(i % 61));
        if ((stds.digest & bit) != 0 or (i % 3) != 0) r.covered += 1;
    }
    r.digest = (@as(u64, r.covered) << 32) ^ r.cells ^ stds.digest;
    return r;
}

pub fn covers(r: *const MapReport, need: u32) bool {
    return r.covered >= need and r.cells > 0;
}
