const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc-2022",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = mode,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |b_args| {
        run_cmd.addArgs(b_args);
    }
    run_cmd.stdio = .inherit;

    const run_step = b.step("run", "Run the program");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run tests");
    const main_tests = b.addExecutable(.{
        .name = "main_tests",
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = mode,
    });
    const run_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_tests.step);

    const write_log_step = std.Build.Step.WriteFile.create(b);
    write_log_step.addBytesToSource(builtin.zig_version_string, "zig-version.txt");
    write_log_step.step.dependOn(&exe.step);
    b.default_step = &write_log_step.step;
}
