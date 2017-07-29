const std = @import("std");
const root = @import("pcm_root");

fn usage() void {
    std.debug.print("usage: pcm <command> <file>\n", .{});
    std.debug.print("commands: validate inspect evaluate process recover export\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();
    _ = args.next();
    const cmd = args.next() orelse {
        usage();
        return error.MissingArg;
    };
    const path = args.next() orelse {
        usage();
        return error.MissingArg;
    };
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const data = try file.readToEndAlloc(gpa, 400000);
    defer gpa.free(data);

    if (std.mem.eql(u8, cmd, "validate")) {
        const r = root.pcm_validate_bytes(data.ptr, data.len);
        std.debug.print("ok={} records={} checksum={x} err={}\n", .{ r.ok, r.record_count, r.checksum, r.error_code });
    } else if (std.mem.eql(u8, cmd, "inspect")) {
        const r = root.pcm_inspect_bytes(data.ptr, data.len);
        std.debug.print("schemes={} standards={} evidence={} decisions={} seals={} recovers={}\n", .{
            r.schemes, r.standards, r.evidence, r.decisions, r.seals, r.recovers,
        });
    } else if (std.mem.eql(u8, cmd, "evaluate")) {
        const r = root.pcm_evaluate_bytes(data.ptr, data.len);
        std.debug.print("effective={} accepted={} decision={} active={} samples={} recall={} verify={}\n", .{
            r.standards_effective, r.evidence_accepted, r.decision, r.certificate_active, r.samples_due, r.recall_armed, r.verify_ok,
        });
    } else if (std.mem.eql(u8, cmd, "process")) {
        const r = root.pcm_process_bytes(data.ptr, data.len);
        std.debug.print("digest={x} sections={} seals={}\n", .{ r.digest, r.sections, r.seals });
    } else if (std.mem.eql(u8, cmd, "recover")) {
        const r = root.pcm_recover_bytes(data.ptr, data.len);
        std.debug.print("digest={x} sections={}\n", .{ r.digest, r.sections });
    } else if (std.mem.eql(u8, cmd, "export")) {
        var buf: [400000]u8 = undefined;
        const r = root.pcm_export_bytes(data.ptr, data.len, &buf, buf.len);
        if (r.error_code != 0 or r.bytes_written == 0) {
            std.debug.print("export failed err={}\n", .{r.error_code});
            return error.ExportFailed;
        }
        const out_path = try std.fmt.allocPrint(gpa, "{s}.out", .{path});
        defer gpa.free(out_path);
        try std.fs.cwd().writeFile(.{ .sub_path = out_path, .data = buf[0..@intCast(r.bytes_written)] });
        std.debug.print("wrote {} bytes digest={x}\n", .{ r.bytes_written, r.digest });
    } else {
        usage();
        return error.UnknownCommand;
    }
}
