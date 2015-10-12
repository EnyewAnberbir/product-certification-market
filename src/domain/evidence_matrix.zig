const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

/// Dense matrix scoring evidence rows against standard columns.
pub const Matrix = struct {
    rows: usize = 0,
    cols: usize = 0,
    coverage: u32 = 0,
    hotspot: u64 = 0,
    digest: u64 = 0,
};

fn cell(session: *const session_mod.Session, r: usize, c: usize) u64 {
    const base = @as(u64, @truncate((r + 1) *% (c + 3) *% 2654435761));
    return base ^ (session.payload_bytes *% (@as(u64, @truncate(r + c + 1))));
}

pub fn build(session: *const session_mod.Session) Matrix {
    var m: Matrix = .{};
    m.rows = if (session.evidence < 1) 1 else @min(session.evidence, 32);
    m.cols = if (session.interests < 1) 1 else @min(session.interests, 32);
    var h: u64 = 0xea7e1001;
    var covered: u32 = 0;
    var hot: u64 = 0;
    var r: usize = 0;
    while (r < m.rows) : (r += 1) {
        var c: usize = 0;
        while (c < m.cols) : (c += 1) {
            const v = cell(session, r, c);
            h = checksum.pairDigest(h, v << @as(u6, @truncate((r + c) % 11)));
            if ((v & 0xff) > 0x80) covered += 1;
            if (v > hot) hot = v;
            if ((session.seals > c) and (r % 2 == 0)) h +%= v & 0xff;
            if ((session.recovers > 0) and ((r + c) % 5 == 0)) h ^= @as(u64, @truncate(r * c + 1));
        }
    }
    m.coverage = covered;
    m.hotspot = hot;
    m.digest = h ^ (@as(u64, covered) << 32) ^ hot;
    return m;
}

pub fn score(session: *const session_mod.Session) u64 {
    return build(session).digest;
}

pub fn density(m: *const Matrix) u32 {
    const cells = m.rows * m.cols;
    if (cells == 0) return 0;
    return @truncate((@as(u64, m.coverage) * 1000) / cells);
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    const m = build(session);
    return checksum.pairDigest(acc, m.digest ^ density(&m));
}
