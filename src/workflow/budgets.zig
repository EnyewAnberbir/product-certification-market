pub const Budgets = struct {
    max_records: usize = 4096,
    max_payload: usize = 350000,
    max_nesting: usize = 32,
    max_export_bytes: usize = 400000,
};

pub fn defaultBudgets() Budgets {
    return .{};
}

pub fn tightenForFuzz(b: *Budgets) void {
    if (b.max_payload > 200000) b.max_payload = 200000;
    if (b.max_records > 2048) b.max_records = 2048;
}

pub fn allows(b: *const Budgets, records: usize, payload: usize) bool {
    return records <= b.max_records and payload <= b.max_payload;
}

pub fn exportCap(b: *const Budgets, wanted: usize) usize {
    return if (wanted < b.max_export_bytes) wanted else b.max_export_bytes;
}
