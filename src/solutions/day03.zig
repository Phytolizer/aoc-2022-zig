const std = @import("std");
const day = @import("../day_interface.zig");
const lines = @import("../lines.zig").lines;

inline fn priority(ch: u8) usize {
    return switch (ch) {
        'a'...'z' => ch - 'a' + 1,
        'A'...'Z' => ch - 'A' + 27,
        else => 0,
    };
}

fn commonPriority(chunk: []const []const u8) usize {
    for (chunk[0]) |ch| {
        var all_have_it = true;
        for (chunk) |line| {
            if (std.mem.indexOfScalar(u8, line, ch) == null) {
                all_have_it = false;
                break;
            }
        }
        if (all_have_it) return priority(ch);
    }
    unreachable;
}

fn inner1(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
    var lines_it = lines(input);
    var result: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len == 0) continue;
        std.debug.assert(@mod(line.len, 2) == 0);

        const half = @divExact(line.len, 2);
        const chunk = [2][]const u8{ line[0..half], line[half..] };
        result += commonPriority(&chunk);
    }
    return try std.fmt.allocPrint(a, "{d}", .{result});
}

fn inner2(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
    var lines_it = lines(input);
    var result: usize = 0;
    var chunk: [3][]const u8 = undefined;
    var i: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len == 0) continue;

        if (i > 0 and i % 3 == 0)
            result += commonPriority(&chunk);
        chunk[i % 3] = line;
        i += 1;
    }
    if (i > 0 and i % 3 == 0)
        result += commonPriority(&chunk);
    return try std.fmt.allocPrint(a, "{d}", .{result});
}

pub fn Solver(comptime part: usize) day.SolveFunc {
    return switch (part) {
        1 => inner1,
        2 => inner2,
        else => @compileError("invalid part given"),
    };
}
