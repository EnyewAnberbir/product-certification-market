const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

/// Bitset clause coverage for mandatory / optional conformity obligations.
pub const Solver = struct {
    mandatory: u64 = 0,
    optional: u64 = 0,
    satisfied: u64 = 0,
    conflicts: u64 = 0,
    digest: u64 = 0,
};

fn bit(n: u6) u64 {
    return @as(u64, 1) << n;
}

pub fn setup(session: *const session_mod.Session) Solver {
    var s: Solver = .{};
    s.mandatory = @as(u64, @truncate(session.titles *% 0x9e3779b9)) | 0xF;
    s.optional = @as(u64, @truncate(session.evidence *% 0x85ebca77)) & ~s.mandatory;
    var present: u64 = 0;
    if (session.seals > 0) present |= 0xFF;
    if (session.evidence > 0) present |= 0xFF00;
    if (session.parties > 0) present |= 0xFF0000;
    if (session.extends > 0) present |= 0xFF000000;
    if (session.recovers > 0) present |= 0xF00000000;
    if (session.queries > 0) present |= 0xF000000000;
    present |= @as(u64, @truncate(session.payload_bytes & 0xffffffff)) << 32;
    s.satisfied = present;

    // Conflict: optional bits that invert mandatory when recover pressure is high.
    if (session.recovers > 2) {
        s.conflicts = (s.optional >> 3) & s.mandatory;
        s.satisfied &= ~s.conflicts;
    }
    s.digest = checksum.pairDigest(s.mandatory, s.optional ^ s.satisfied ^ s.conflicts);
    return s;
}

pub fn mandatoryMet(s: *const Solver) bool {
    return (s.satisfied & s.mandatory) == s.mandatory;
}

pub fn optionalScore(s: *const Solver) u32 {
    return @popCount(s.satisfied & s.optional);
}

pub fn repairHint(s: *const Solver) u64 {
    return s.mandatory & ~s.satisfied;
}

pub fn softPass(s: *const Solver, min_optional: u32) bool {
    return mandatoryMet(s) and optionalScore(s) >= min_optional and s.conflicts == 0;
}

pub fn applyWaiver(s: *Solver, mask: u64) void {
    s.satisfied |= mask & s.mandatory;
    s.conflicts &= ~mask;
    s.digest = checksum.pairDigest(s.digest, mask);
}

pub fn clauseWeight(s: *const Solver, idx: u6) u32 {
    const m = bit(idx);
    var w: u32 = 0;
    if ((s.mandatory & m) != 0) w += 10;
    if ((s.optional & m) != 0) w += 3;
    if ((s.satisfied & m) != 0) w += 1;
    if ((s.conflicts & m) != 0) w += 7;
    return w;
}

pub fn portfolioScore(s: *const Solver) u64 {
    var total: u64 = 0;
    var i: u6 = 0;
    while (true) {
        total += clauseWeight(s, i);
        if (i == 63) break;
        i += 1;
    }
    return total ^ (@as(u64, @popCount(s.conflicts)) << 48);
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    var s = setup(session);
    if (!mandatoryMet(&s) and session.extends > 0) {
        applyWaiver(&s, repairHint(&s) & 0xFF);
    }
    var h = checksum.pairDigest(acc, s.digest);
    h ^= if (softPass(&s, 2)) @as(u64, 1) else repairHint(&s);
    h ^= optionalScore(&s);
    h ^= portfolioScore(&s);
    return h;
}
