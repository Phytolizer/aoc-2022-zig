const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("aoc-2022", "src/main.zig");
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |b_args| {
        run_cmd.addArgs(b_args);
    }
    run_cmd.expected_exit_code = null;

    const run_step = b.step("run", "Run the program");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run tests");
    const main_tests = b.addExecutable("main_tests", "src/test.zig");
    main_tests.setBuildMode(mode);
    const run_tests = main_tests.run();
    test_step.dependOn(&run_tests.step);
}
