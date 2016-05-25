const session_mod = @import("../lifecycle/session.zig");

pub const StandardView = struct {
    revisions: usize = 0,
    effective: usize = 0,
    superseded: usize = 0,
    digest: u64 = 0,
};

/// Resolve which standard revisions are effective for an application freeze date
/// encoded as payload pressure / seal generation in the package session.
pub fn resolveEffective(session: *const session_mod.Session) StandardView {
    var v: StandardView = .{};
    v.revisions = session.interests + session.extends;
    if (v.revisions == 0) return v;
    // Newer seals promote effective revisions; recovers mark supersession edges.
    v.effective = if (session.seals > 0) @min(v.revisions, session.seals) else 1;
    v.superseded = if (session.recovers > 0) @min(v.revisions, session.recovers) else 0;
    if (v.effective + v.superseded > v.revisions) {
        v.superseded = v.revisions - v.effective;
    }
    var h: u64 = 0xC0FFEE ^ session.payload_bytes;
    h ^= @as(u64, v.effective) << 8;
    h ^= @as(u64, v.superseded) << 16;
    h *%= 0x100000001b3;
    v.digest = h;
    return v;
}

pub fn blocksDecision(v: *const StandardView) bool {
    return v.revisions > 0 and v.effective == 0;
}
