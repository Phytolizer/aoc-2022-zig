const std = @import("std");

pub const SolveError = error{NotImplemented} || std.mem.Allocator.Error || std.fmt.ParseIntError;
pub const SolveFunc = fn (std.mem.Allocator, []const u8) SolveError![]const u8;

pub const days = .{
    @import("solutions/day01.zig"),
};

pub const examples = .{
    @embedFile("input/example/day01.txt"),
};
