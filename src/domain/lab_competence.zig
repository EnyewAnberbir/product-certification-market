pub fn accreditationWindowOk(start_day: u32, end_day: u32, as_of: u32) bool {
    return as_of >= start_day and as_of <= end_day;
}

pub fn methodInScope(method_mask: u32, required_bit: u5) bool {
    return ((method_mask >> required_bit) & 1) == 1;
}

pub fn measurementUncertaintyOk(expanded_milli: u32, limit_milli: u32) bool {
    return expanded_milli <= limit_milli;
}

pub fn foldLabDigest(lab_id: u32, methods: u32, as_of: u32) u64 {
    var h: u64 = lab_id;
    h ^= methods;
    h *%= 0x9e3779b97f4a7c15;
    h ^= as_of;
    return h ^ (h >> 33);
}
