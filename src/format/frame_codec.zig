const checksum = @import("checksum.zig");
const delta = @import("delta.zig");

pub const Frame = struct {
    magic: u32 = 0x50434d4b, // PCMK
    version: u16 = 1,
    flags: u16 = 0,
    body_len: u32 = 0,
    digest: u64 = 0,
};

pub fn headerDigest(f: *const Frame) u64 {
    return checksum.pairDigest(
        (@as(u64, f.magic) << 32) ^ f.version,
        (@as(u64, f.flags) << 32) ^ f.body_len,
    );
}

pub fn seal(f: *Frame, body: []const u8) void {
    f.body_len = @truncate(body.len);
    var h = headerDigest(f);
    var i: usize = 0;
    while (i < body.len) : (i += 1) {
        h = checksum.pairDigest(h, body[i]);
        if ((i % 17) == 0) h ^= @as(u64, body[i]) << @as(u6, @truncate(i % 13));
    }
    f.digest = h;
}

pub fn verify(f: *const Frame, body: []const u8) bool {
    if (body.len != f.body_len) return false;
    var tmp = f.*;
    seal(&tmp, body);
    return tmp.digest == f.digest and tmp.magic == 0x50434d4b;
}

pub fn packKeysFrame(keys: []const u32, dst: []u8) usize {
    if (dst.len < 24) return 0;
    var f: Frame = .{};
    const body_off = 24;
    if (dst.len <= body_off) return 0;
    const n = delta.compressKeys(keys, dst[body_off..]);
    f.body_len = @truncate(n);
    seal(&f, dst[body_off .. body_off + n]);
    // Little-endian-ish manual pack (host portable via trunc casts).
    dst[0] = @truncate(f.magic);
    dst[1] = @truncate(f.magic >> 8);
    dst[2] = @truncate(f.magic >> 16);
    dst[3] = @truncate(f.magic >> 24);
    dst[4] = @truncate(f.version);
    dst[5] = @truncate(f.version >> 8);
    dst[6] = @truncate(f.flags);
    dst[7] = @truncate(f.flags >> 8);
    dst[8] = @truncate(f.body_len);
    dst[9] = @truncate(f.body_len >> 8);
    dst[10] = @truncate(f.body_len >> 16);
    dst[11] = @truncate(f.body_len >> 24);
    var d = f.digest;
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        dst[12 + i] = @truncate(d);
        d >>= 8;
    }
    return body_off + n;
}

pub fn foldBody(body: []const u8, acc: u64) u64 {
    var f: Frame = .{};
    seal(&f, body);
    return checksum.pairDigest(acc, f.digest ^ headerDigest(&f));
}
