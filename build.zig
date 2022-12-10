const std = @import("std");

const DAYS_IMPLEMENTED = 6;

const RenderArgs = struct {
    day: []const u8 = "",
    daynum: []const u8 = "",
    daynumfmt: []const u8 = "",
    implnum: []const u8 = std.fmt.comptimePrint("{d}", .{DAYS_IMPLEMENTED}),
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
        else if (std.mem.eql(u8, var_name, "daynumfmt"))
            args.daynumfmt
        else if (std.mem.eql(u8, var_name, "implnum"))
            args.implnum
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

    var day_nums: [DAYS_IMPLEMENTED]usize = undefined;
    {
        var day_num: usize = 0;
        while (day_num < DAYS_IMPLEMENTED) : (day_num += 1) {
            day_nums[day_num] = day_num + 1;
        }
    }
    var days: [DAYS_IMPLEMENTED][]u8 = undefined;
    for (day_nums) |day| {
        days[day - 1] = try std.fmt.allocPrint(b.allocator, "{d}", .{day});
    }
    var days_fmt: [DAYS_IMPLEMENTED][]u8 = undefined;
    for (day_nums) |day| {
        days_fmt[day - 1] = try std.fmt.allocPrint(b.allocator, "{d:0>2}", .{day});
    }
    var day_names: [DAYS_IMPLEMENTED][]u8 = undefined;
    for (day_nums) |day| {
        day_names[day - 1] = try std.fmt.allocPrint(b.allocator, "dec{s}", .{days_fmt[day - 1]});
    }
    defer for (day_nums) |day| {
        b.allocator.free(days[day - 1]);
        b.allocator.free(day_names[day - 1]);
    };

    const header = @embedFile("templates/header.template");
    const import_day = @embedFile("templates/import_day.template");
    const input = @embedFile("templates/input.template");
    const run_day = @embedFile("templates/run_day.template");
    const run_particular_day = @embedFile("templates/run_particular_day.template");
    const run_day_end = @embedFile("templates/run_day_end.template");
    const kinds = &[_][]const u8{ "simple", "full" };

    var all_input_f = try std.fs.cwd().createFile("src/all_input.zig", .{});
    var all_input = all_input_f.writer();

    for (day_nums) |day| {
        for (kinds) |kind| {
            try renderTemplate(
                input,
                @TypeOf(all_input),
                all_input,
                .{
                    .day = day_names[day - 1],
                    .daynumfmt = days_fmt[day - 1],
                    .kind = kind,
                },
            );
        }
    }

    var all_days_f = try std.fs.cwd().createFile("src/all_days.zig", .{});
    var all_days = all_days_f.writer();

    try all_days.writeAll(header);
    for (day_nums) |day| {
        try renderTemplate(
            import_day,
            @TypeOf(all_days),
            all_days,
            .{ .day = day_names[day - 1], .daynum = days[day - 1] },
        );
    }
    try renderTemplate(run_day, @TypeOf(all_days), all_days, .{});

    for (day_nums) |day| {
        try renderTemplate(
            run_particular_day,
            @TypeOf(all_days),
            all_days,
            .{ .day = day_names[day - 1], .daynum = days[day - 1] },
        );
    }

    try all_days.writeAll(run_day_end);
    all_days_f.close();

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

    const fragment = @embedFile("templates/test_fragment.template");

    const amalgamated_test_path = "src/test.zig";
    const amalgamated_test = try std.fs.cwd().createFile(amalgamated_test_path, .{});
    var writer = amalgamated_test.writer();
    try writer.writeAll(header);

    for (day_nums) |day_num| {
        {
            try renderTemplate(
                import_day,
                @TypeOf(writer),
                writer,
                .{ .day = day_names[day_num - 1], .daynum = days[day_num - 1] },
            );

            const parts = &[_][]const u8{ "1", "2" };

            for (parts) |part| {
                for (kinds) |kind| {
                    try renderTemplate(
                        fragment,
                        @TypeOf(writer),
                        writer,
                        .{
                            .day = day_names[day_num - 1],
                            .daynum = days[day_num - 1],
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
