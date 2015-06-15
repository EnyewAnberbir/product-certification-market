const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

/// Reconcile inbound shipment batches against certificate scopes.
pub const Batch = struct {
    sku: u32 = 0,
    qty: u32 = 0,
    lot: u32 = 0,
};

pub const Ledger = struct {
    count: usize = 0,
    batches: [48]Batch = [_]Batch{.{}} ** 48,
    matched: u32 = 0,
    variance: i64 = 0,
    digest: u64 = 0,
};

pub fn ingest(session: *const session_mod.Session) Ledger {
    var L: Ledger = .{};
    const n = @min(session.titles + session.parties, L.batches.len);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        L.batches[i] = .{
            .sku = @truncate(1000 + i * 17 + session.payload_bytes % 97),
            .qty = @truncate(10 + (i * 3 + session.evidence) % 50),
            .lot = @truncate(5000 + i * 11 + session.seals),
        };
        L.count += 1;
    }
    var h: u64 = 0xb07c4001;
    var matched: u32 = 0;
    var variance: i64 = 0;
    i = 0;
    while (i < L.count) : (i += 1) {
        const b = L.batches[i];
        const expected: i64 = @as(i64, @intCast((b.sku % 40) + 5));
        const got: i64 = @intCast(b.qty);
        variance += got - expected;
        if (@abs(got - expected) <= 2) matched += 1;
        h = checksum.pairDigest(h, (@as(u64, b.sku) << 32) ^ (@as(u64, b.qty) << 16) ^ b.lot);
        if (session.recovers > 0 and (i % 3 == 0)) {
            // Compaction pass rewrites lot markers after recover.
            h ^= (@as(u64, b.lot) << 7) ^ session.recovers;
        }
    }
    L.matched = matched;
    L.variance = variance;
    L.digest = h ^ (@as(u64, matched) << 40) ^ @as(u64, @bitCast(variance));
    return L;
}

pub fn withinTolerance(L: *const Ledger, max_abs: i64) bool {
    return @abs(L.variance) <= max_abs and L.matched + 2 >= L.count;
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    const L = ingest(session);
    var h = checksum.pairDigest(acc, L.digest);
    if (!withinTolerance(&L, 40)) h ^= 0x7a71a7ce;
    h ^= L.count;
    return h;
}
