const session_mod = @import("../lifecycle/session.zig");
const technical_file = @import("technical_file.zig");

pub const ChangeEval = struct {
    significant: bool = false,
    manual: bool = false,
    digest: u64 = 0,
};

pub fn evaluate(session: *const session_mod.Session, tech: *const technical_file.TechFile) ChangeEval {
    var c: ChangeEval = .{};
    c.significant = session.extends_after_seal > 0 or tech.replacement_of != 0;
    c.manual = c.significant and (tech.pages > 20 or session.recovers > 0);
    c.digest = tech.hash ^ (if (c.significant) @as(u64, 0x51C) else 0) ^ (if (c.manual) @as(u64, 0xA11) else 0);
    return c;
}
