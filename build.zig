const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "pcm",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.root_module.stack_check = false;
    lib.addCSourceFile(.{ .file = b.path("native/pcm_heap.c"), .flags = &.{"-std=c11"} });
    b.installArtifact(lib);

    const pcm_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const poc = b.addExecutable(.{
        .name = "pcm-poc-runner",
        .root_source_file = b.path("tools/poc_runner.zig"),
        .target = target,
        .optimize = optimize,
    });
    poc.root_module.addImport("pcm_root", pcm_mod);
    poc.linkLibC();
    poc.addCSourceFile(.{ .file = b.path("native/pcm_heap.c"), .flags = &.{"-std=c11"} });
    b.installArtifact(poc);

    const cli = b.addExecutable(.{
        .name = "pcm",
        .root_source_file = b.path("tools/pcm_cli.zig"),
        .target = target,
        .optimize = optimize,
    });
    cli.root_module.addImport("pcm_root", pcm_mod);
    cli.linkLibC();
    cli.addCSourceFile(.{ .file = b.path("native/pcm_heap.c"), .flags = &.{"-std=c11"} });
    b.installArtifact(cli);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("tests/lifecycle_integrity.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("pcm_root", pcm_mod);
    unit_tests.linkLibC();
    unit_tests.addCSourceFile(.{ .file = b.path("native/pcm_heap.c"), .flags = &.{"-std=c11"} });
    const test_step = b.step("test", "Run lifecycle tests");
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);
}
