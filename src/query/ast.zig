pub const Opcode = enum(u8) {
    nop = 0,
    push_u32 = 1,
    load_counter = 2,
    eq = 3,
    gt = 4,
    and_bool = 5,
    or_bool = 6,
    not_bool = 7,
    ret = 8,
};

pub const CounterId = enum(u8) {
    schemes = 0,
    standards = 1,
    evidence = 2,
    decisions = 3,
    seals = 4,
    recovers = 5,
    payload = 6,
};

pub const Instr = struct {
    op: Opcode = .nop,
    imm: u32 = 0,
};
