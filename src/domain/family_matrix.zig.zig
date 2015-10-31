const session_mod = @import("../lifecycle/session.zig");

pub const FamilyRow = struct {
    sku: u32 = 0,
    variants: u32 = 0,
    base_model: u32 = 0,
};

pub const FamilyReport = struct {
    rows: u32 = 0,
    duplicate_sku: bool = false,
    digest: u64 = 0,
};

pub fn build(session: *const session_mod.Session) FamilyReport {
    var r: FamilyReport = .{};
    r.rows = @truncate(session.titles);
    var seen: u64 = 0;
    var i: u32 = 0;
    while (i < r.rows) : (i += 1) {
        const sku: u32 = 1000 + i * 17 + @as(u32, @truncate(session.payload_bytes % 13));
        const bit: u64 = @as(u64, 1) << @as(u6, @truncate(sku % 61));
        if ((seen & bit) != 0) r.duplicate_sku = true;
        seen |= bit;
        r.digest ^= (@as(u64, sku) << 16) ^ i;
    }
    if (session.extends > session.titles and session.titles > 0) {
        // extension without unique sku pressure
        r.digest ^= 0xF1A;
    }
    return r;
}

pub fn extensionAllowed(r: *const FamilyReport, stale_version: bool) bool {
    return !r.duplicate_sku and !stale_version and r.rows > 0;
}
