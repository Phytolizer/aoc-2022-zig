const std = @import("std");
const day = @import("../day_interface.zig");
const lines = @import("../lines.zig").lines;

const Sign = enum(usize) { rock = 1, paper = 2, scissors = 3 };

fn elf(line: []const u8) Sign {
    return switch (line[0]) {
        'A' => .rock,
        'B' => .paper,
        'C' => .scissors,
        else => unreachable,
    };
}

fn human1(line: []const u8) Sign {
    return switch (line[2]) {
        'X' => .rock,
        'Y' => .paper,
        'Z' => .scissors,
        else => unreachable,
    };
}

inline fn next(sign: Sign) Sign {
    return switch (sign) {
        .rock => .paper,
        .paper => .scissors,
        .scissors => .rock,
    };
}

fn human2(line: []const u8) Sign {
    return switch (line[2]) {
        'X' => next(next(elf(line))),
        'Y' => elf(line),
        'Z' => next(elf(line)),
        else => unreachable,
    };
}

fn score(elf_sign: Sign, human_sign: Sign) usize {
    return if (human_sign == next(elf_sign))
        6 + @intFromEnum(human_sign)
    else if (human_sign == elf_sign)
        3 + @intFromEnum(human_sign)
    else
        @intFromEnum(human_sign);
}

fn total(input: []const u8, comptime elf_cb: fn ([]const u8) Sign, comptime human_cb: fn ([]const u8) Sign) usize {
    var lines_it = lines(input);
    var result: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len < 3) continue;
        result += score(elf_cb(line), human_cb(line));
    }
    return result;
}

fn inner(
    a: std.mem.Allocator,
    input: []const u8,
    comptime elf_cb: fn ([]const u8) Sign,
    comptime human_cb: fn ([]const u8) Sign,
) day.SolveError![]const u8 {
    const result = total(input, elf_cb, human_cb);
    return try std.fmt.allocPrint(a, "{d}", .{result});
}

pub fn Solver(comptime part: usize) day.SolveFunc {
    return switch (part) {
        1 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, elf, human1);
            }
        }.solve,
        2 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, elf, human2);
            }
        }.solve,
        else => @compileError("invalid part given"),
    };
}
