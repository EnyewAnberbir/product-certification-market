const session_mod = @import("../lifecycle/session.zig");
const checksum = @import("../format/checksum.zig");

pub const Trail = struct {
    events: u32 = 0,
    head: u64 = 0,
    sealed: bool = false,
};

pub fn build(session: *const session_mod.Session) Trail {
    var t: Trail = .{};
    t.events = @truncate(session.seals + session.recovers + session.compacts + session.queries);
    var h: u64 = 0xA0D17;
    var i: u32 = 0;
    while (i < t.events and i < 128) : (i += 1) {
        h = checksum.pairDigest(h, (@as(u64, i) << 8) ^ session.payload_bytes);
    }
    t.head = h;
    t.sealed = session.saw_seal;
    return t;
}

pub fn appendEvent(t: *Trail, kind: u32, payload: u64) void {
    t.events += 1;
    t.head = checksum.pairDigest(t.head, (@as(u64, kind) << 32) ^ payload);
}
