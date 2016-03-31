const certificates = @import("certificates.zig");

pub const VerifyResult = struct {
    ok: bool = false,
    reason: u32 = 0,
    digest: u64 = 0,
};

pub fn verifyMark(cert: *const certificates.CertificateView, mark_prefix: u32, model_units: u32) VerifyResult {
    var r: VerifyResult = .{};
    if (!cert.active) {
        r.reason = 1;
    } else if (cert.mark_prefix != mark_prefix) {
        r.reason = 2;
    } else if (model_units > cert.scope_units) {
        r.reason = 3;
    } else {
        r.ok = true;
    }
    r.digest = cert.digest ^ mark_prefix ^ model_units ^ r.reason;
    return r;
}
