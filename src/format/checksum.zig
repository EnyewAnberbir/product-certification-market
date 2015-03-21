const std = @import("std");

pub fn fnv1a64(data: []const u8) u64 {
    var h: u64 = 0xcbf29ce484222325;
    for (data) |b| {
        h ^= b;
        h *%= 0x100000001b3;
    }
    return h;
}

pub fn fnv1a64Seeded(seed: u64, data: []const u8) u64 {
    var h = seed ^ 0xcbf29ce484222325;
    for (data) |b| {
        h ^= b;
        h *%= 0x100000001b3;
    }
    return h;
}

pub fn rollingXor32(data: []const u8) u32 {
    var a: u32 = 0x811c9dc5;
    var i: usize = 0;
    while (i < data.len) : (i += 1) {
        a ^= data[i];
        a *%= 0x01000193;
        a ^= a >> 7;
    }
    return a;
}

pub fn pairDigest(a: u64, b: u64) u64 {
    var h = a ^ (b << 1) ^ (b >> 3);
    h *%= 0x9e3779b97f4a7c15;
    h ^= h >> 33;
    return h;
}

pub fn sectionDigest(tag: u8, key: u32, payload: []const u8) u64 {
    var h: u64 = 0xA5A5A5A5A5A5A5A5 ^ tag;
    h ^= key;
    h *%= 0x100000001b3;
    return fnv1a64Seeded(h, payload);
}

pub fn combineMany(parts: []const u64) u64 {
    var h: u64 = 0x6a09e667f3bcc909;
    for (parts) |p| {
        h ^= p;
        h *%= 0x9e3779b97f4a7c15;
        h ^= h >> 29;
    }
    return h;
}
