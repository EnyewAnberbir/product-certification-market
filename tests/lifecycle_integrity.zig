const std = @import("std");
const root = @import("pcm_root");

test "empty input is quiet" {
    const stats = root.pcm_process_bytes(&[_]u8{}, 0);
    try std.testing.expect(stats.sections == 0);
}

test "validate rejects empty buffer" {
    const r = root.pcm_validate_bytes(&[_]u8{}, 0);
    try std.testing.expect(r.ok == 0);
}

test "inspect quiet on empty" {
    const r = root.pcm_inspect_bytes(&[_]u8{}, 0);
    try std.testing.expect(r.schemes == 0);
    try std.testing.expect(r.evidence == 0);
}

test "evaluate quiet on empty" {
    const r = root.pcm_evaluate_bytes(&[_]u8{}, 0);
    try std.testing.expect(r.digest == 0 or r.certificate_active == 0);
}
