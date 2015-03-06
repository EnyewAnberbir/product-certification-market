const workflow = @import("workflow/driver.zig");
const engine = @import("domain/engine.zig");

pub const WorkflowStats = workflow.WorkflowStats;
pub const ValidateResult = workflow.ValidateResult;
pub const InspectResult = workflow.InspectResult;
pub const ExportResult = workflow.ExportResult;
pub const EngineReport = engine.EngineReport;

pub export fn pcm_process_bytes(data: [*]const u8, size: usize) callconv(.C) WorkflowStats {
    return workflow.driveBytes(data[0..size]);
}

pub export fn pcm_validate_bytes(data: [*]const u8, size: usize) callconv(.C) ValidateResult {
    return workflow.validateBytes(data[0..size]);
}

pub export fn pcm_inspect_bytes(data: [*]const u8, size: usize) callconv(.C) InspectResult {
    return workflow.inspectBytes(data[0..size]);
}

pub export fn pcm_evaluate_bytes(data: [*]const u8, size: usize) callconv(.C) EngineReport {
    return workflow.evaluateBytes(data[0..size]);
}

pub export fn pcm_recover_bytes(data: [*]const u8, size: usize) callconv(.C) WorkflowStats {
    return workflow.recoverBytes(data[0..size]);
}

pub export fn pcm_export_bytes(
    data: [*]const u8,
    size: usize,
    out: [*]u8,
    out_cap: usize,
) callconv(.C) ExportResult {
    return workflow.exportBytes(data[0..size], out[0..out_cap]);
}

pub export fn pcm_verify_mark(
    data: [*]const u8,
    size: usize,
    mark_prefix: u32,
    model_units: u32,
) callconv(.C) u64 {
    return workflow.verifyMark(data[0..size], mark_prefix, model_units);
}
