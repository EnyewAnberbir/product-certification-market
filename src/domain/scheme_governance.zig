const session_mod = @import("../lifecycle/session.zig");

pub const SchemeState = struct {
    active: usize = 0,
    suspended: usize = 0,
    withdrawn: usize = 0,
    digest: u64 = 0,
};

pub fn evaluateSchemes(session: *const session_mod.Session) SchemeState {
    var s: SchemeState = .{};
    s.active = session.titles;
    if (session.recovers > 0 and session.compacts > 0) {
        s.suspended = session.recovers;
        if (session.compacts > session.recovers) s.withdrawn = session.compacts - session.recovers;
    }
    var h: u64 = 0x811c9dc5;
    h ^= session.titles;
    h *%= 0x01000193;
    h ^= session.seals;
    h *%= 0x01000193;
    h ^= session.payload_bytes;
    s.digest = h;
    return s;
}

pub fn scopeOverlap(a_units: u32, b_units: u32) u32 {
    if (a_units == 0 or b_units == 0) return 0;
    return if (a_units < b_units) a_units else b_units;
}

pub fn freezeAllowed(open_nonconformities: u32, critical: u32) bool {
    return critical == 0 and open_nonconformities < 8;
}
