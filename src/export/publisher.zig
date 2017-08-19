const manifest = @import("manifest.zig");
const audit_trail = @import("audit_trail.zig");
const session_mod = @import("../lifecycle/session.zig");
const certificates = @import("../domain/certificates.zig");

pub const PublishReport = struct {
    manifest_entries: u32 = 0,
    audit_events: u32 = 0,
    digest: u64 = 0,
};

pub fn publish(session: *const session_mod.Session, cert: *const certificates.CertificateView) PublishReport {
    const man = manifest.build(session, cert);
    const trail = audit_trail.build(session);
    return .{
        .manifest_entries = man.entries,
        .audit_events = trail.events,
        .digest = man.digest ^ trail.head ^ (if (trail.sealed) @as(u64, 1) else 0),
    };
}
