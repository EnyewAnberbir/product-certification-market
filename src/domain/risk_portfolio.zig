const factory_audit = @import("factory_audit.zig");
const surveillance = @import("surveillance.zig");
const complaints = @import("complaints.zig");
const recalls = @import("recalls.zig");

pub const Portfolio = struct {
    band: u8 = 0,
    score: u64 = 0,
    watchlist: bool = false,
};

pub fn score(
    audit: *const factory_audit.AuditFinding,
    surv: *const surveillance.SurveillancePlan,
    complaint: *const complaints.ComplaintCase,
    recall: *const recalls.RecallNotice,
) Portfolio {
    var p: Portfolio = .{};
    var s: u64 = audit.score;
    s +%= surv.samples_due *% 17;
    s +%= complaint.severity *% 100;
    if (recall.armed) s +%= 500;
    if (surv.overdue_critical) s +%= 300;
    p.score = s;
    p.band = if (s > 800) 3 else if (s > 400) 2 else if (s > 100) 1 else 0;
    p.watchlist = p.band >= 2 or recall.armed;
    return p;
}
