const types = @import("types.zig");
const checksum = @import("../format/checksum.zig");
const session_mod = @import("../lifecycle/session.zig");

pub fn builtinEpoch(session: *const session_mod.Session) types.SchemaEpoch {
    var e: types.SchemaEpoch = .{};
    e.version = @truncate(1 + session.gens % 7);
    e.field_count = @truncate(8 + session.titles % 12);
    e.digest = checksum.pairDigest(e.version, e.field_count ^ session.payload_bytes);
    return e;
}

pub fn compatible(prev: types.SchemaEpoch, next: types.SchemaEpoch) bool {
    if (next.version < prev.version) return false;
    if (next.field_count + 4 < prev.field_count) return false;
    return true;
}

pub fn migrateDigest(prev: types.SchemaEpoch, next: types.SchemaEpoch) u64 {
    return checksum.pairDigest(prev.digest, next.digest ^ (@as(u64, next.version) << 8));
}

pub fn requiredMask(epoch: types.SchemaEpoch) u64 {
    var m: u64 = 0;
    var i: u16 = 0;
    while (i < epoch.field_count and i < 61) : (i += 1) {
        if ((i % 3) == 0) m |= @as(u64, 1) << @as(u6, @truncate(i));
    }
    return m;
}
