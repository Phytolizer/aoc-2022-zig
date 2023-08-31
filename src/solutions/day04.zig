const std = @import("std");
const day = @import("../day_interface.zig");
const lines = @import("../lines.zig").lines;

const Range = struct { from: usize, to: usize };

fn contains(r1: Range, r2: Range) bool {
    return r1.from <= r2.from and r1.to >= r2.to;
}

fn overlaps(r1: Range, r2: Range) bool {
    return r1.to >= r2.from and r1.from <= r2.to;
}

fn parseRanges(line: []const u8) ![2]Range {
    var result: [2]Range = undefined;
    var comma = std.mem.splitScalar(u8, line, ',');
    for (0..2) |i| {
        const range = comma.next().?;
        var hyphen = std.mem.splitScalar(u8, range, '-');
        result[i] = Range{
            .from = try std.fmt.parseInt(usize, hyphen.next().?, 10),
            .to = try std.fmt.parseInt(usize, hyphen.next().?, 10),
        };
    }
    return result;
}

fn duplicatedWorkCount(input: []const u8, comptime rangeCheck: fn (Range, Range) bool) !usize {
    var result: usize = 0;
    var lines_it = lines(input);
    while (lines_it.next()) |line| {
        if (line.len == 0) continue;
        const ranges = try parseRanges(line);
        result += @intFromBool(rangeCheck(ranges[0], ranges[1]) or rangeCheck(ranges[1], ranges[0]));
    }
    return result;
}

fn inner(a: std.mem.Allocator, input: []const u8, comptime rangeCheck: fn (Range, Range) bool) day.SolveError![]const u8 {
    return try std.fmt.allocPrint(a, "{d}", .{try duplicatedWorkCount(input, rangeCheck)});
}

pub fn Solver(comptime part: usize) day.SolveFunc {
    return switch (part) {
        1 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, contains);
            }
        }.solve,
        2 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, overlaps);
            }
        }.solve,
        else => @compileError("invalid part given"),
    };
}
