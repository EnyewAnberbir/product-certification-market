const std = @import("std");
const root = @import("pcm_root");

pub fn main() !void {
    var gpa = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();
    _ = args.next();
    const path = args.next() orelse {
        std.debug.print("usage: pcm-poc-runner <file>\n", .{});
        return error.MissingArg;
    };
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const data = try file.readToEndAlloc(gpa, 400000);
    defer gpa.free(data);
    const stats = root.pcm_process_bytes(data.ptr, data.len);
    std.debug.print("digest={x} sections={} titles={}\n", .{ stats.digest, stats.sections, stats.titles });
}
