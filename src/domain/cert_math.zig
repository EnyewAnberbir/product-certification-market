const std = @import("std");

/// Coverage of accredited scheme clauses versus declared product scope units.
pub fn schemeCoverageRatio(scheme_units: u64, scope_units: u64) u64 {
    if (scheme_units == 0) return 0;
    return (scope_units * 1000) / scheme_units;
}

/// Factory surveillance intensity: samples collected per production unit.
pub fn surveillanceCoverage(factory_units: u64, sample_units: u64) u64 {
    if (factory_units == 0) return 0;
    return (sample_units * 100) / factory_units;
}

pub fn priorityOk(required: u32, provided: u32) bool {
    return provided >= required;
}

pub fn sampleDemand(units: u32, rate_num: u32, rate_den: u32) u32 {
    if (rate_den == 0) return units;
    return (units * rate_num + rate_den - 1) / rate_den;
}

pub fn foldCertMetrics(seed: u64, lot: u64, bldg: u64, units: u32) u64 {
    var h = seed ^ schemeCoverageRatio(lot, bldg);
    h ^= surveillanceCoverage(lot, bldg / 2);
    h ^= sampleDemand(units, 3, 2);
    h *%= 0x9e3779b97f4a7c15;
    return h ^ (if (priorityOk(10, 12)) @as(u64, 1) else 0);
}

pub fn capaDeadlineDays(severity: u8, base_days: u32) u32 {
    return switch (severity) {
        3 => base_days / 2,
        2 => base_days,
        1 => base_days + base_days / 2,
        else => base_days * 2,
    };
}

pub fn quorumMet(votes_for: u32, votes_against: u32, quorum: u32) bool {
    const total = votes_for + votes_against;
    if (total < quorum) return false;
    return votes_for > votes_against;
}
