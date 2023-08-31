const std = @import("std");

pub const SolveError = error{NotImplemented} || std.mem.Allocator.Error || std.fmt.ParseIntError;
pub const SolveFunc = fn (std.mem.Allocator, []const u8) SolveError![]const u8;

pub const days = .{
    @import("solutions/day01.zig"),
    @import("solutions/day02.zig"),
    @import("solutions/day03.zig"),
    @import("solutions/day04.zig"),
};

pub const examples = .{
    @embedFile("input/example/day01.txt"),
    @embedFile("input/example/day02.txt"),
    @embedFile("input/example/day03.txt"),
    @embedFile("input/example/day04.txt"),
};

pub const example_solutions = .{
    .{ "24000", "45000" },
    .{ "15", "12" },
    .{ "157", "70" },
    .{ "2", "4" },
};
