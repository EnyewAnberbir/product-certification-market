const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const EventKind = enum(u8) {
    submit = 1,
    evidence = 2,
    seal = 3,
    recover = 4,
    compact = 5,
    export_evt = 6,
    appeal = 7,
    renew = 8,
};

pub const Event = struct {
    kind: EventKind = .submit,
    at: u32 = 0,
    key: u32 = 0,
};

pub const Timeline = struct {
    count: usize = 0,
    events: [80]Event = [_]Event{.{}} ** 80,
    digest: u64 = 0,
};

fn push(t: *Timeline, kind: EventKind, at: u32, key: u32) void {
    if (t.count >= t.events.len) return;
    t.events[t.count] = .{ .kind = kind, .at = at, .key = key };
    t.count += 1;
}

pub fn build(session: *const session_mod.Session) Timeline {
    var t: Timeline = .{};
    var clock: u32 = 10;
    var i: usize = 0;
    while (i < session.titles and i < 20) : (i += 1) {
        push(&t, .submit, clock, @truncate(100 + i));
        clock += 3 + @as(u32, @truncate(i % 4));
    }
    i = 0;
    while (i < session.evidence and i < 20) : (i += 1) {
        push(&t, .evidence, clock, @truncate(200 + i));
        clock += 5;
    }
    i = 0;
    while (i < session.seals and i < 12) : (i += 1) {
        push(&t, .seal, clock, @truncate(500 + i));
        clock += 7;
    }
    i = 0;
    while (i < session.recovers and i < 10) : (i += 1) {
        push(&t, .recover, clock, @truncate(700 + i));
        clock += 4;
        push(&t, .compact, clock, @truncate(800 + i));
        clock += 2;
    }
    if (session.parties > 2) {
        push(&t, .appeal, clock, 850);
        clock += 6;
    }
    if (session.extends > 0) {
        push(&t, .renew, clock, 900);
        clock += 8;
    }
    push(&t, .export_evt, clock, 999);

    var h: u64 = 0x71e00100;
    var e: usize = 0;
    while (e < t.count) : (e += 1) {
        const ev = t.events[e];
        h = checksum.pairDigest(h, (@as(u64, @intFromEnum(ev.kind)) << 40) ^ (@as(u64, ev.at) << 16) ^ ev.key);
    }
    t.digest = h ^ (@as(u64, @truncate(t.count)) << 8);
    return t;
}

pub fn isMonotonic(t: *const Timeline) bool {
    if (t.count < 2) return true;
    var i: usize = 1;
    while (i < t.count) : (i += 1) {
        if (t.events[i].at < t.events[i - 1].at) return false;
    }
    return true;
}

pub fn span(t: *const Timeline) u32 {
    if (t.count == 0) return 0;
    return t.events[t.count - 1].at -% t.events[0].at;
}

pub fn countKind(t: *const Timeline, kind: EventKind) u32 {
    var n: u32 = 0;
    var i: usize = 0;
    while (i < t.count) : (i += 1) {
        if (t.events[i].kind == kind) n += 1;
    }
    return n;
}

pub fn lastOf(t: *const Timeline, kind: EventKind) ?Event {
    var i: usize = t.count;
    while (i > 0) {
        i -= 1;
        if (t.events[i].kind == kind) return t.events[i];
    }
    return null;
}

pub fn fold(session: *const session_mod.Session, acc: u64) u64 {
    const t = build(session);
    var h = checksum.pairDigest(acc, t.digest);
    if (!isMonotonic(&t)) h ^= 0xbad00001;
    h ^= span(&t);
    h ^= (@as(u64, countKind(&t, .seal)) << 24) ^ countKind(&t, .recover);
    if (lastOf(&t, .export_evt)) |ev| h ^= ev.key;
    return h;
}
