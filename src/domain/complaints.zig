const session_mod = @import("../lifecycle/session.zig");
const certificates = @import("certificates.zig");
const cert_math = @import("cert_math.zig");

pub const ComplaintCase = struct {
    severity: u8 = 0,
    capa_days: u32 = 0,
    suspends: bool = false,
    digest: u64 = 0,
};

pub fn triage(session: *const session_mod.Session, cert: *const certificates.CertificateView) ComplaintCase {
    var c: ComplaintCase = .{};
    if (session.queries == 0) return c;
    c.severity = if (session.recovers >= 2) 3 else if (session.compacts >= 2) 2 else 1;
    c.capa_days = cert_math.capaDeadlineDays(c.severity, 30);
    c.suspends = c.severity >= 3 and cert.active;
    c.digest = (@as(u64, c.severity) << 40) ^ c.capa_days ^ cert.digest;
    return c;
}
