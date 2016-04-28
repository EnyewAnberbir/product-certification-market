const session_mod = @import("../lifecycle/session.zig");
const certificates = @import("certificates.zig");

pub const RenewalWindow = struct {
    open: bool = false,
    days_left: u32 = 0,
    requires_retest: bool = false,
    digest: u64 = 0,
};

pub fn evaluate(session: *const session_mod.Session, cert: *const certificates.CertificateView) RenewalWindow {
    var w: RenewalWindow = .{};
    if (!cert.active) return w;
    const age = @as(u32, @truncate(session.seals * 90 + session.queries * 7));
    w.days_left = if (age < 365) 365 - age else 0;
    w.open = w.days_left > 0 and w.days_left < 120;
    w.requires_retest = session.extends > 0 or session.recovers > 0;
    w.digest = (@as(u64, w.days_left) << 16) ^ (if (w.open) @as(u64, 1) else 0) ^ cert.digest;
    return w;
}
