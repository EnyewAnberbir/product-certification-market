const format = @import("../format/container.zig");

pub const Session = extern struct {
    titles: usize = 0,
    interests: usize = 0,
    evidence: usize = 0,
    parties: usize = 0,
    seals: usize = 0,
    recovers: usize = 0,
    compacts: usize = 0,
    extends: usize = 0,
    extends_after_seal: usize = 0,
    gens: usize = 0,
    queries: usize = 0,
    payload_bytes: usize = 0,
    first_seal_index: usize = 0,
    first_recover_index: usize = 0,
    first_compact_after_recover: usize = 0,
    saw_seal: bool = false,
    saw_recover: bool = false,
    cancel_armed: bool = false,
};

pub fn buildSession(env: *const format.Envelope) Session {
    var s: Session = .{};
    var idx: usize = 0;
    while (idx < env.record_count) : (idx += 1) {
        const r = env.records[idx];
        s.payload_bytes += r.payload_len + 16;
        switch (r.op) {
            .title => s.titles += 1,
            .interest => s.interests += 1,
            .evidence => s.evidence += 1,
            .party => s.parties += 1,
            .seal => {
                s.seals += 1;
                s.gens += 1;
                if (!s.saw_seal) {
                    s.saw_seal = true;
                    s.first_seal_index = idx;
                }
            },
            .compact => {
                s.compacts += 1;
                s.gens += 1;
                if (s.saw_recover and s.first_compact_after_recover == 0)
                    s.first_compact_after_recover = idx;
            },
            .recover => {
                s.recovers += 1;
                s.gens += 1;
                if (!s.saw_recover) {
                    s.saw_recover = true;
                    s.first_recover_index = idx;
                }
            },
            .extend => {
                s.extends += 1;
                if (s.saw_seal) s.extends_after_seal += 1;
            },
            .query => s.queries += 1,
            .export_op => s.gens += 1,
            else => {},
        }
    }
    s.payload_bytes += 10;
    s.cancel_armed = s.saw_recover and s.first_compact_after_recover > s.first_recover_index;
    return s;
}

pub fn recordLike(self: *const Session) bool {
    return self.titles + self.interests + self.evidence + self.parties + self.seals > 0;
}
