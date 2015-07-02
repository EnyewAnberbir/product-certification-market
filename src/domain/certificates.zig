const session_mod = @import("../lifecycle/session.zig");
const decisions = @import("decisions.zig");

pub const CertificateView = struct {
    active: bool = false,
    scope_units: u32 = 0,
    mark_prefix: u32 = 0,
    digest: u64 = 0,
};

pub fn issue(session: *const session_mod.Session, dec: *const decisions.DecisionReport) CertificateView {
    var c: CertificateView = .{};
    c.active = dec.outcome == .approved and session.saw_seal;
    c.scope_units = @as(u32, @truncate(session.titles * 3 + session.extends));
    c.mark_prefix = @as(u32, @truncate((session.payload_bytes ^ session.seals) & 0xffff));
    c.digest = (@as(u64, c.mark_prefix) << 16) ^ c.scope_units ^ (if (c.active) @as(u64, 1) else 0);
    return c;
}

pub fn suspendScope(c: *CertificateView, partial: bool) void {
    if (!c.active) return;
    if (partial) {
        c.scope_units = c.scope_units / 2;
    } else {
        c.active = false;
        c.scope_units = 0;
    }
    c.digest ^= 0xA11CE;
}
