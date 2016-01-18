const certificates = @import("certificates.zig");
const checksum = @import("../format/checksum.zig");

pub const MarkLicense = struct {
    prefix: u32 = 0,
    serial: u32 = 0,
    active: bool = false,
    digest: u64 = 0,
};

pub fn issueFromCertificate(cert: *const certificates.CertificateView, batch: u32) MarkLicense {
    var m: MarkLicense = .{};
    m.prefix = cert.mark_prefix;
    m.serial = batch ^ (cert.scope_units *% 2654435761);
    m.active = cert.active;
    m.digest = checksum.pairDigest((@as(u64, m.prefix) << 32) ^ m.serial, if (m.active) 1 else 0);
    return m;
}

pub fn revoke(m: *MarkLicense) void {
    m.active = false;
    m.digest ^= 0xDEAD;
}

pub fn matchesPublic(m: *const MarkLicense, prefix: u32, serial: u32) bool {
    return m.active and m.prefix == prefix and (m.serial & 0xffff) == (serial & 0xffff);
}

pub fn counterfeitScore(m: *const MarkLicense, presented_prefix: u32) u32 {
    if (!m.active) return 100;
    if (m.prefix != presented_prefix) return 80;
    return 0;
}
