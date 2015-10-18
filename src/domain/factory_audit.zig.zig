const session_mod = @import("../lifecycle/session.zig");
const cert_math = @import("cert_math.zig");

pub const AuditFinding = struct {
    major: u32 = 0,
    minor: u32 = 0,
    critical: u32 = 0,
    score: u64 = 0,
};

pub fn scoreVisit(session: *const session_mod.Session) AuditFinding {
    var f: AuditFinding = .{};
    f.minor = @truncate(session.extends % 5);
    f.major = @truncate(session.compacts % 4);
    f.critical = if (session.recovers >= 2) 1 else 0;
    const weight = f.critical * 40 + f.major * 15 + f.minor * 5;
    f.score = cert_math.foldCertMetrics(session.payload_bytes, session.titles + 1, session.evidence + 1, weight);
    return f;
}

pub fn requiresFollowUp(f: *const AuditFinding) bool {
    return f.critical > 0 or f.major >= 2 or f.score > 0x80000000;
}

pub fn capaWindow(f: *const AuditFinding) u32 {
    if (f.critical > 0) return cert_math.capaDeadlineDays(3, 14);
    if (f.major > 0) return cert_math.capaDeadlineDays(2, 30);
    return cert_math.capaDeadlineDays(1, 60);
}

pub fn mergeFindings(a: AuditFinding, b: AuditFinding) AuditFinding {
    return .{
        .major = a.major + b.major,
        .minor = a.minor + b.minor,
        .critical = a.critical + b.critical,
        .score = a.score ^ (b.score << 1) ^ (b.score >> 3),
    };
}

pub fn riskBand(f: *const AuditFinding) u8 {
    if (f.critical > 0) return 3;
    if (f.major >= 2) return 2;
    if (f.minor >= 3 or f.major == 1) return 1;
    return 0;
}
