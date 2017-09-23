pub const FieldKind = enum(u8) {
    u32_le = 1,
    u64_le = 2,
    bytes = 3,
    utf8 = 4,
    bool8 = 5,
    enum8 = 6,
};

pub const FieldDecl = struct {
    id: u16 = 0,
    kind: FieldKind = .u32_le,
    required: bool = false,
    max_len: u16 = 0,
};

pub const SchemaEpoch = struct {
    version: u16 = 1,
    field_count: u16 = 0,
    digest: u64 = 0,
};
