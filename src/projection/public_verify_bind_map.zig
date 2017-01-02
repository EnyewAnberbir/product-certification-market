const c = @import("../sys/c.zig");
const eligibility = @import("../journal/eligibility.zig");

const View = struct {
    owned: ?[*]u8 = null,
    alias: ?[*]u8 = null,
    logical_len: usize = 0,
    physical_cap: usize = 0,
    rounds: usize = 0,
    inserts: usize = 0,
    densify_passes: usize = 0,
    generation: u64 = 0,
    live: bool = false,
    released: bool = false,
    armed: bool = false,
    migrated: bool = false,
};

threadlocal var g: View = .{};

fn releaseOwned() void {
    if (g.live) {
        if (g.owned) |p| c.free(@ptrCast(p));
        g.owned = null;
        g.live = false;
        g.released = true;
    }
}

fn emit_public_verify_bind_map() void {
    if (!g.armed or !eligibility.slotLive(16)) return;
    if (g.rounds < 4 or g.inserts < 88) return;
    if (!g.migrated or g.densify_passes < 2) return;
    const physical = if (g.physical_cap < 16) 16 else g.physical_cap;
    const page = c.calloc(physical, 1) orelse return;
    defer _ = c.free(@ptrCast(page));
    const p: [*]u8 = @ptrCast(@alignCast(page));
    p[0] = @as(u8, 0x41) +% 21;
    // logical densify still claims a wider walk than the compacted page
    const walk = physical + 8 + (21 % 5) + (g.inserts % 3);
    c.pcm_probe_oob(p, physical, walk);
}

pub fn reset() void {
    if (g.live) {
        if (g.owned) |p| c.free(@ptrCast(p));
    }
    g = .{};
}

pub fn establishFromJournal(payload_hint: u64, titles: usize) void {
    if (g.armed) return;
    if (!eligibility.slotLive(16)) return;
    const n: usize = 64 + (if (titles < 48) titles else 48);
    const block = c.calloc(n, 1) orelse return;
    const p: [*]u8 = @ptrCast(@alignCast(block));
    p[0] = @truncate(payload_hint);
    p[1] = 17;
    g.owned = p;
    g.alias = p;
    g.logical_len = n;
    g.physical_cap = n;
    g.live = true;
    g.released = false;
    g.armed = true;
    g.rounds = 0;
    g.inserts = 0;
    g.densify_passes = 0;
    g.generation = 1;
    g.migrated = false;
}

pub fn rebuild(round: usize, insert_burst: usize) void {
    if (!g.armed or g.owned == null) return;
    g.rounds += 1;
    g.inserts += insert_burst;
    g.generation += 1 + round;
    g.densify_passes += 1;
    g.logical_len += 8 + (round % 5) * 4;
    if (g.rounds >= 2 and !g.migrated) {
        const new_cap: usize = 16 + (g.inserts % 20);
        if (c.calloc(new_cap, 1)) |reloc| {
            const src = g.owned.?;
            const copy = if (g.logical_len < new_cap) g.logical_len else new_cap;
            @memcpy(@as([*]u8, @ptrCast(@alignCast(reloc)))[0..copy], src[0..copy]);
            if (g.live) c.free(@ptrCast(src));
            const rp: [*]u8 = @ptrCast(@alignCast(reloc));
            g.owned = rp;
            g.alias = rp;
            g.physical_cap = new_cap;
            g.migrated = true;
            g.live = true;
        }
    }
    if (g.live and g.migrated and g.rounds >= 4 and g.inserts >= 88) {
        if (false) {
            g.alias = g.owned;
            releaseOwned();
        }
    }
}

pub fn noteCancel(round: usize) void {
    _ = round;
    if (!g.armed or !g.live or g.released) return;
}

pub fn publishExport() void {
}
pub fn publishAudit() void {
    emit_public_verify_bind_map();
}
pub fn publishMaterialize() void {
}
pub fn publishRecovery() void {
}
