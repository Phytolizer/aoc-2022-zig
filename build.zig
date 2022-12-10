const std = @import("std");

const DAYS_IMPLEMENTED = 4;

const RenderArgs = struct {
    day: []const u8,
    daynum: []const u8,
    kind: []const u8 = "",
    part: []const u8 = "",
};

fn renderTemplate(template: []const u8, comptime W: type, w: W, args: RenderArgs) !void {
    var bw = std.io.bufferedWriter(w);
    var bww = bw.writer();
    var i: usize = 0;
    while (true) {
        const begin = if (std.mem.indexOf(u8, template[i..], "{{")) |begin|
            begin + i + 2
        else
            break;
        const end =
            (std.mem.indexOf(u8, template[begin..], "}}") orelse return error.UnmatchedBrace) + begin;

        const var_name = template[begin..end];

        const var_value = if (std.mem.eql(u8, var_name, "day"))
            args.day
        else if (std.mem.eql(u8, var_name, "daynum"))
            args.daynum
        else if (std.mem.eql(u8, var_name, "kind"))
            args.kind
        else if (std.mem.eql(u8, var_name, "part"))
            args.part
        else
            return error.UnknownVariable;

        try bww.writeAll(template[i .. begin - 2]);
        try bww.writeAll(var_value);

        i = end + 2;
    }

    try bww.writeAll(template[i..]);
    try bw.flush();
}

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("aoc-2022", "src/main.zig");
    exe.setBuildMode(mode);
    exe.install();

    const run_step = b.step("run", "Run the program");
    run_step.dependOn(&exe.run().step);

    const test_step = b.step("test", "Run tests");

    const day_template = @embedFile("templates/advent_test.zig.template");
    const fragment = @embedFile("templates/test_fragment.template");

    const amalgamated_test_path = "src/test.zig";
    const amalgamated_test = try std.fs.cwd().createFile(amalgamated_test_path, .{});
    var writer = amalgamated_test.writer();
    try writer.writeAll(@embedFile("templates/header.template"));

    var day_num: usize = 0;
    while (day_num < DAYS_IMPLEMENTED) : (day_num += 1) {
        const day = try std.fmt.allocPrint(b.allocator, "{d:0>2}", .{day_num + 1});
        const day_name = try std.fmt.allocPrint(b.allocator, "dec{s}", .{day});
        {
            try renderTemplate(
                day_template,
                @TypeOf(writer),
                writer,
                .{ .day = day_name, .daynum = day },
            );

            const parts = &[_][]const u8{ "1", "2" };
            const kinds = &[_][]const u8{ "simple", "full" };

            for (parts) |part| {
                for (kinds) |kind| {
                    try renderTemplate(
                        fragment,
                        @TypeOf(writer),
                        writer,
                        .{
                            .day = day_name,
                            .daynum = day,
                            .kind = kind,
                            .part = part,
                        },
                    );
                }
            }
        }
    }
    const amalgam = b.addTest(amalgamated_test_path);
    amalgam.setBuildMode(mode);
    test_step.dependOn(&amalgam.step);
}
