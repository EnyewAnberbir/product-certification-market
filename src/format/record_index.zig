const container = @import("container.zig");
const checksum = @import("checksum.zig");

pub const IndexEntry = struct {
    op: u8 = 0,
    key: u32 = 0,
    offset: u32 = 0,
    length: u32 = 0,
};

pub const Index = struct {
    count: usize = 0,
    digest: u64 = 0,
    // Fixed capacity keeps indexing offline/no-alloc.
    entries: [256]IndexEntry = [_]IndexEntry{.{}} ** 256,
};

pub fn build(env: *const container.Envelope) Index {
    var idx: Index = .{};
    var off: u32 = 10;
    var i: usize = 0;
    while (i < env.record_count and idx.count < idx.entries.len) : (i += 1) {
        const r = env.records[i];
        idx.entries[idx.count] = .{
            .op = @intFromEnum(r.op),
            .key = r.key,
            .offset = off,
            .length = @truncate(14 + r.payload_len),
        };
        off += @truncate(14 + r.payload_len);
        idx.count += 1;
    }
    var h: u64 = 0x1DE0;
    var j: usize = 0;
    while (j < idx.count) : (j += 1) {
        const e = idx.entries[j];
        h = checksum.pairDigest(h, (@as(u64, e.op) << 48) ^ (@as(u64, e.key) << 16) ^ e.offset ^ e.length);
    }
    idx.digest = h;
    return idx;
}

pub fn findByKey(idx: *const Index, key: u32) ?usize {
    var i: usize = 0;
    while (i < idx.count) : (i += 1) {
        if (idx.entries[i].key == key) return i;
    }
    return null;
}

pub fn countOp(idx: *const Index, op: u8) usize {
    var n: usize = 0;
    var i: usize = 0;
    while (i < idx.count) : (i += 1) {
        if (idx.entries[i].op == op) n += 1;
    }
    return n;
}
