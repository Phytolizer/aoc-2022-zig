const std = @import("std");
const day = @import("../day_interface.zig");
const lines = @import("../lines.zig").lines;

fn inner(a: std.mem.Allocator, input: []const u8, comptime num_groups: usize) day.SolveError![]const u8 {
    var lines_it = lines(input);
    var groups = std.ArrayList(usize).init(a);
    defer groups.deinit();
    try groups.append(0);
    while (lines_it.next()) |line| {
        if (line.len == 0) {
            try groups.append(0);
        } else {
            const n = try std.fmt.parseInt(usize, line, 10);
            groups.items[groups.items.len - 1] += n;
        }
    }
    std.mem.sortUnstable(usize, groups.items, {}, std.sort.desc(usize));
    var result: usize = 0;
    for (groups.items[0..num_groups]) |g| result += g;
    return try std.fmt.allocPrint(a, "{d}", .{result});
}
pub fn Solver(comptime part: usize) day.SolveFunc {
    return switch (part) {
        1 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, 1);
            }
        }.solve,
        2 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, 3);
            }
        }.solve,
        else => @compileError("invalid part given"),
    };
}
