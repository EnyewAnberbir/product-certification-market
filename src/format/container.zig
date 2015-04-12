const std = @import("std");
const c = @import("../sys/c.zig");

pub const Op = enum(u8) {
    none = 0,
    title = 1,
    interest = 2,
    evidence = 3,
    party = 4,
    seal = 5,
    recover = 6,
    compact = 7,
    extend = 8,
    query = 9,
    export_op = 10,
    _,
};

pub const Record = extern struct {
    op: Op = .none,
    key: u32 = 0,
    aux: u32 = 0,
    payload_len: usize = 0,
    payload: ?[*]u8 = null,
};

pub const Envelope = extern struct {
    version: u16 = 0,
    flags: u16 = 0,
    record_count: usize = 0,
    records: [*]Record = undefined,
    owned: bool = false,
};

pub const WireReport = extern struct {
    ok: bool = false,
    checksum: u64 = 0,
};

fn readU16(data: []const u8, off: usize) ?u16 {
    if (off + 2 > data.len) return null;
    return @as(u16, data[off]) | (@as(u16, data[off + 1]) << 8);
}
fn readU32(data: []const u8, off: usize) ?u32 {
    if (off + 4 > data.len) return null;
    return @as(u32, data[off]) | (@as(u32, data[off + 1]) << 8) | (@as(u32, data[off + 2]) << 16) | (@as(u32, data[off + 3]) << 24);
}

pub fn parseEnvelope(data: []const u8) Envelope {
    var env: Envelope = .{};
    if (data.len < 10) return env;
    if (data[0] != 'P' or data[1] != 'C' or data[2] != 'M' or data[3] != 'K') return env;
    env.version = readU16(data, 4) orelse return env;
    env.flags = readU16(data, 6) orelse return env;
    const count = readU16(data, 8) orelse return env;
    if (count > 4096) return env;
    const recs = c.calloc(count, @sizeOf(Record)) orelse return env;
    env.records = @ptrCast(@alignCast(recs));
    env.owned = true;
    var off: usize = 10;
    var i: usize = 0;
    while (i < count) : (i += 1) {
        if (off + 14 > data.len) break;
        const op: Op = @enumFromInt(data[off]);
        const key = readU32(data, off + 4) orelse break;
        const aux = readU32(data, off + 8) orelse break;
        const plen = readU16(data, off + 12) orelse break;
        off += 14;
        if (off + plen > data.len) break;
        var rec: Record = .{ .op = op, .key = key, .aux = aux, .payload_len = plen, .payload = null };
        if (plen > 0) {
            const buf = c.malloc(plen) orelse break;
            const bp: [*]u8 = @ptrCast(@alignCast(buf));
            @memcpy(bp[0..plen], data[off .. off + plen]);
            rec.payload = bp;
        }
        env.records[i] = rec;
        env.record_count += 1;
        off += plen;
    }
    return env;
}

pub fn validateEnvelope(env: *const Envelope) WireReport {
    var report: WireReport = .{};
    var h: u64 = 0xcbf29ce484222325;
    var i: usize = 0;
    while (i < env.record_count) : (i += 1) {
        const r = env.records[i];
        h ^= @intFromEnum(r.op);
        h *%= 0x100000001b3;
        h ^= r.key;
        h *%= 0x100000001b3;
        h ^= r.payload_len;
        h *%= 0x100000001b3;
        if (r.payload) |p| {
            var j: usize = 0;
            while (j < r.payload_len) : (j += 1) {
                h ^= p[j];
                h *%= 0x100000001b3;
            }
        }
    }
    report.checksum = h;
    report.ok = env.record_count > 0;
    return report;
}

pub fn freeEnvelope(env: *Envelope) void {
    if (!env.owned) return;
    var i: usize = 0;
    while (i < env.record_count) : (i += 1) {
        if (env.records[i].payload) |p| c.free(@ptrCast(p));
    }
    c.free(@ptrCast(env.records));
    env.* = .{};
}

pub fn findPackageBounds(data: []const u8) struct { start: usize, end: usize } {
    if (data.len < 10) return .{ .start = 0, .end = 0 };
    if (data[0] == 'P' and data[1] == 'C' and data[2] == 'M' and data[3] == 'K') {
        return .{ .start = 0, .end = data.len };
    }
    var i: usize = 0;
    while (i + 4 <= data.len) : (i += 1) {
        if (data[i] == 'P' and data[i + 1] == 'C' and data[i + 2] == 'M' and data[i + 3] == 'K') {
            return .{ .start = i, .end = data.len };
        }
    }
    return .{ .start = 0, .end = 0 };
}

fn writeU16(buf: []u8, off: usize, v: u16) void {
    buf[off] = @truncate(v);
    buf[off + 1] = @truncate(v >> 8);
}
fn writeU32(buf: []u8, off: usize, v: u32) void {
    buf[off] = @truncate(v);
    buf[off + 1] = @truncate(v >> 8);
    buf[off + 2] = @truncate(v >> 16);
    buf[off + 3] = @truncate(v >> 24);
}

/// Canonical little-endian re-encode of a parsed envelope.
pub fn serializeEnvelope(env: *const Envelope, out: []u8) usize {
    if (!env.owned and env.record_count == 0) return 0;
    var need: usize = 10;
    var i: usize = 0;
    while (i < env.record_count) : (i += 1) {
        need += 14 + env.records[i].payload_len;
    }
    if (out.len < need) return 0;
    out[0] = 'P';
    out[1] = 'C';
    out[2] = 'M';
    out[3] = 'K';
    writeU16(out, 4, env.version);
    writeU16(out, 6, env.flags);
    writeU16(out, 8, @truncate(env.record_count));
    var off: usize = 10;
    i = 0;
    while (i < env.record_count) : (i += 1) {
        const r = env.records[i];
        out[off] = @intFromEnum(r.op);
        out[off + 1] = 0;
        writeU16(out, off + 2, 0);
        writeU32(out, off + 4, r.key);
        writeU32(out, off + 8, r.aux);
        writeU16(out, off + 12, @truncate(r.payload_len));
        off += 14;
        if (r.payload_len > 0) {
            if (r.payload) |p| {
                @memcpy(out[off .. off + r.payload_len], p[0..r.payload_len]);
            }
            off += r.payload_len;
        }
    }
    return off;
}
