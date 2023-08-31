const std = @import("std");
const day = @import("../day_interface.zig");
const lines = @import("../lines.zig").lines;

const Move = struct {
    count: usize,
    source: *std.ArrayList(u8),
    target: *std.ArrayList(u8),
};

fn crateMover9000(move: Move) !void {
    std.debug.print("{any} {d}-> {any}\n", .{ move.source.items, move.count, move.target.items });
    try move.target.ensureUnusedCapacity(move.count);
    for (0..move.count) |_| {
        move.target.appendAssumeCapacity(move.source.pop());
    }
    std.debug.print("{any} {d}-> {any}\n", .{ move.source.items, move.count, move.target.items });
}

fn crateMover9001(move: Move) !void {
    const end = move.source.items.len - move.count;
    const tail = move.source.items[end..];
    try move.target.appendSlice(tail);
    move.source.shrinkRetainingCapacity(end);
}

fn inner(
    a: std.mem.Allocator,
    input: []const u8,
    comptime mover: fn (Move) std.mem.Allocator.Error!void,
) day.SolveError![]const u8 {
    var lines_it = lines(input);
    var stack_defs = std.ArrayList([]const u8).init(a);
    defer stack_defs.deinit();

    while (lines_it.next()) |line| {
        if (line.len == 0)
            // end of crates
            break;

        try stack_defs.append(line);
    }

    var stacks = std.ArrayList(std.ArrayList(u8)).init(a);
    defer {
        for (stacks.items) |stack| stack.deinit();
        stacks.deinit();
    }
    // FIXME: probably off by one in here somewhere
    const stack_count = stack_defs.items[stack_defs.items.len - 1].len / 4 + 1;
    for (0..stack_count) |_| try stacks.append(std.ArrayList(u8).init(a));

    for (0..stack_defs.items.len - 1) |rev_i| {
        const i = stack_count - 1 - rev_i;
        const line = stack_defs.items[i];
        for (0..line.len / 4 + 1) |crate_num| {
            const stack = &stacks.items[crate_num];
            const crate = line[crate_num * 4 + 1];
            if (crate != ' ') try stack.append(crate);
        }
    }

    while (lines_it.next()) |line| {
        if (line.len == 0) continue;
        const digits = "0123456789";
        const count_start = std.mem.indexOfAny(u8, line, digits).?;
        const count_end = std.mem.indexOfNonePos(u8, line, count_start, digits).?;
        const count = try std.fmt.parseInt(usize, line[count_start..count_end], 10);
        const source_start = std.mem.indexOfAnyPos(u8, line, count_end, digits).?;
        const source_end = std.mem.indexOfNonePos(u8, line, source_start, digits).?;
        const source = try std.fmt.parseInt(usize, line[source_start..source_end], 10);
        const target_start = std.mem.indexOfAnyPos(u8, line, source_end, digits).?;
        const target = try std.fmt.parseInt(usize, line[target_start..], 10);
        try mover(.{
            .count = count,
            .source = &stacks.items[source - 1],
            .target = &stacks.items[target - 1],
        });
    }

    const result = try a.alloc(u8, stacks.items.len);
    for (stacks.items, 0..) |stack, i| {
        result[i] = stack.items[stack.items.len - 1];
    }
    return result;
}

pub fn Solver(comptime part: usize) day.SolveFunc {
    return switch (part) {
        1 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, crateMover9000);
            }
        }.solve,
        2 => struct {
            fn solve(a: std.mem.Allocator, input: []const u8) day.SolveError![]const u8 {
                return inner(a, input, crateMover9001);
            }
        }.solve,
        else => @compileError("invalid part given"),
    };
}
