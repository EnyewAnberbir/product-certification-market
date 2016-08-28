const format = @import("../format/container.zig");
const session_mod = @import("../lifecycle/session.zig");
const runtime = @import("../projection/runtime.zig");
const stages = @import("../pipeline/stages.zig");
const engine = @import("../domain/engine.zig");
const certificates = @import("../domain/certificates.zig");
const decisions = @import("../domain/decisions.zig");
const standards = @import("../domain/standards.zig");
const evidence = @import("../domain/evidence.zig");
const public_verify = @import("../domain/public_verify.zig");

pub const WorkflowStats = extern struct {
    sections: u64 = 0,
    titles: u64 = 0,
    seals: u64 = 0,
    payload_bytes: u64 = 0,
    digest: u64 = 0,
};

pub const ValidateResult = extern struct {
    ok: u64 = 0,
    record_count: u64 = 0,
    checksum: u64 = 0,
    error_code: u64 = 0,
};

pub const InspectResult = extern struct {
    schemes: u64 = 0,
    standards: u64 = 0,
    evidence: u64 = 0,
    decisions: u64 = 0,
    seals: u64 = 0,
    recovers: u64 = 0,
    payload_bytes: u64 = 0,
    digest: u64 = 0,
};

pub const ExportResult = extern struct {
    bytes_written: u64 = 0,
    digest: u64 = 0,
    error_code: u64 = 0,
};

fn driveOne(data: []const u8, stats: *WorkflowStats) void {
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const validation = format.validateEnvelope(&env);
    if (!validation.ok and env.record_count == 0) return;
    const session = session_mod.buildSession(&env);
    // Projection densify/export observers must run before domain engine folds so
    // sanitizer-visible page walks are reachable on crashing inputs.
    runtime.establishAll(&session);
    stages.runDensify(&session);
    stages.runLateObservers();
    const report = engine.run(&session);
    runtime.resetAll();
    stats.sections += env.record_count;
    stats.titles += session.titles;
    stats.seals += session.seals;
    stats.payload_bytes += session.payload_bytes;
    stats.digest ^= validation.checksum ^ session.payload_bytes ^ session.extends_after_seal
        ^ report.digest ^ session.titles ^ session.gens;
}

pub fn driveBytes(data: []const u8) WorkflowStats {
    var stats: WorkflowStats = .{};
    if (data.len > 400000) return stats;
    var off: usize = 0;
    var sessions: usize = 0;
    while (off + 10 <= data.len and sessions < 4) {
        var i = off;
        var found: ?usize = null;
        while (i + 4 <= data.len) : (i += 1) {
            if (data[i] == 'P' and data[i + 1] == 'C' and data[i + 2] == 'M' and data[i + 3] == 'K') {
                found = i;
                break;
            }
        }
        if (found == null) break;
        const start = found.?;
        var end = data.len;
        var j = start + 4;
        while (j + 4 <= data.len) : (j += 1) {
            if (j > start + 4 and data[j] == 'P' and data[j + 1] == 'C' and data[j + 2] == 'M' and data[j + 3] == 'K') {
                end = j;
                break;
            }
        }
        driveOne(data[start..end], &stats);
        off = end;
        sessions += 1;
    }
    if (sessions == 0 and data.len >= 10) driveOne(data, &stats);
    return stats;
}

pub fn validateBytes(data: []const u8) ValidateResult {
    var out: ValidateResult = .{};
    if (data.len > 400000) {
        out.error_code = 1;
        return out;
    }
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const v = format.validateEnvelope(&env);
    out.record_count = env.record_count;
    out.checksum = v.checksum;
    out.ok = if (v.ok) 1 else 0;
    out.error_code = if (v.ok) 0 else 2;
    return out;
}

pub fn inspectBytes(data: []const u8) InspectResult {
    var out: InspectResult = .{};
    if (data.len > 400000) return out;
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const session = session_mod.buildSession(&env);
    out.schemes = session.titles;
    out.standards = session.interests;
    out.evidence = session.evidence;
    out.decisions = session.parties;
    out.seals = session.seals;
    out.recovers = session.recovers;
    out.payload_bytes = session.payload_bytes;
    out.digest = session.payload_bytes ^ session.titles ^ session.seals ^ session.gens;
    return out;
}

pub fn evaluateBytes(data: []const u8) engine.EngineReport {
    const empty: engine.EngineReport = .{};
    if (data.len > 400000) return empty;
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const session = session_mod.buildSession(&env);
    return engine.run(&session);
}

pub fn recoverBytes(data: []const u8) WorkflowStats {
    // Recovery entry reuses the workflow but forces journal observers via same densify path.
    return driveBytes(data);
}

pub fn exportBytes(data: []const u8, out_buf: []u8) ExportResult {
    var result: ExportResult = .{};
    if (data.len > 400000) {
        result.error_code = 1;
        return result;
    }
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const v = format.validateEnvelope(&env);
    if (!v.ok) {
        result.error_code = 2;
        return result;
    }
    const n = format.serializeEnvelope(&env, out_buf);
    if (n == 0) {
        result.error_code = 3;
        return result;
    }
    result.bytes_written = n;
    result.digest = v.checksum ^ n;
    return result;
}

pub fn verifyMark(data: []const u8, mark_prefix: u32, model_units: u32) u64 {
    if (data.len > 400000) return 0;
    var env = format.parseEnvelope(data);
    defer format.freeEnvelope(&env);
    const session = session_mod.buildSession(&env);
    const stds = standards.resolveEffective(&session);
    const ev = evidence.evaluate(&session, &stds);
    const dec = decisions.evaluate(&session, &stds, &ev);
    const cert = certificates.issue(&session, &dec);
    const ver = public_verify.verifyMark(&cert, mark_prefix, model_units);
    return if (ver.ok) 1 else 0;
}
