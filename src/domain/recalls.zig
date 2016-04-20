const session_mod = @import("../lifecycle/session.zig");
const certificates = @import("certificates.zig");
const complaints = @import("complaints.zig");

pub const RecallNotice = struct {
    armed: bool = false,
    wave: u32 = 0,
    digest: u64 = 0,
};

pub fn maybeArm(
    session: *const session_mod.Session,
    cert: *const certificates.CertificateView,
    complaint: *const complaints.ComplaintCase,
) RecallNotice {
    var n: RecallNotice = .{};
    n.armed = complaint.suspends or (session.evidence > 0 and session.recovers >= 2 and cert.active);
    n.wave = if (n.armed) @as(u32, @truncate(session.seals + session.queries)) else 0;
    n.digest = (@as(u64, n.wave) << 8) ^ (if (n.armed) @as(u64, 1) else 0) ^ complaint.digest;
    return n;
}
