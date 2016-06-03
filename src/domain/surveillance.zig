const session_mod = @import("../lifecycle/session.zig");
const cert_math = @import("cert_math.zig");
const certificates = @import("certificates.zig");

pub const SurveillancePlan = struct {
    samples_due: u32 = 0,
    overdue_critical: bool = false,
    digest: u64 = 0,
};

pub fn plan(session: *const session_mod.Session, cert: *const certificates.CertificateView) SurveillancePlan {
    var p: SurveillancePlan = .{};
    if (!cert.active) return p;
    p.samples_due = cert_math.sampleDemand(cert.scope_units, 1, 4);
    if (session.queries > p.samples_due and session.recovers > 0) {
        p.overdue_critical = true;
    }
    p.digest = (@as(u64, p.samples_due) << 12) ^ (if (p.overdue_critical) @as(u64, 0xC) else 0) ^ cert.digest;
    return p;
}
