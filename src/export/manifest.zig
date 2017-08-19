const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");
const certificates = @import("../domain/certificates.zig");

pub const Manifest = struct {
    entries: u32 = 0,
    digest: u64 = 0,
};

pub fn build(session: *const session_mod.Session, cert: *const certificates.CertificateView) Manifest {
    var m: Manifest = .{};
    m.entries = @truncate(session.titles + session.evidence + (if (cert.active) @as(usize, 1) else 0));
    m.digest = checksum.pairDigest(session.payload_bytes, cert.digest ^ m.entries);
    var i: u32 = 0;
    while (i < m.entries and i < 64) : (i += 1) {
        m.digest ^= (@as(u64, i) *% 0x9e3779b97f4a7c15) ^ cert.mark_prefix;
    }
    return m;
}
