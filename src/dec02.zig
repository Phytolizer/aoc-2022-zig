const std = @import("std");
const Allocator = std.mem.Allocator;
const helpers = @import("helpers.zig");

const Context = struct {
    total: usize = 0,
    part: usize,

    pub fn init(part: usize) @This() {
        return .{ .part = part };
    }

    const Shape = enum {
        rock,
        paper,
        scissors,
    };

    const Result = enum {
        loss,
        draw,
        win,
    };

    fn parseShape(c: u8) !Shape {
        return switch (c) {
            'A', 'X' => .rock,
            'B', 'Y' => .paper,
            'C', 'Z' => .scissors,
            else => return error.InvalidInput,
        };
    }

    fn parseResult(c: u8) !Result {
        return switch (c) {
            'X' => .loss,
            'Y' => .draw,
            'Z' => .win,
            else => return error.InvalidInput,
        };
    }

    fn scoreGame(player: Shape, result: Result) usize {
        const result_score: usize = switch (result) {
            .loss => 0,
            .draw => 3,
            .win => 6,
        };

        const shape_score: usize = switch (player) {
            .rock => 1,
            .paper => 2,
            .scissors => 3,
        };

        return result_score + shape_score;
    }

    fn play(opponent: Shape, player: Shape) Result {
        return switch (opponent) {
            .rock => switch (player) {
                .rock => .draw,
                .paper => .win,
                .scissors => .loss,
            },
            .paper => switch (player) {
                .rock => .loss,
                .paper => .draw,
                .scissors => .win,
            },
            .scissors => switch (player) {
                .rock => .win,
                .paper => .loss,
                .scissors => .draw,
            },
        };
    }

    fn determinePlay(opponent: Shape, result: Result) Shape {
        return switch (opponent) {
            .rock => switch (result) {
                .loss => .scissors,
                .draw => .rock,
                .win => .paper,
            },
            .paper => switch (result) {
                .loss => .rock,
                .draw => .paper,
                .win => .scissors,
            },
            .scissors => switch (result) {
                .loss => .paper,
                .draw => .scissors,
                .win => .rock,
            },
        };
    }

    pub fn handleLine(self: *@This(), line: []const u8) !void {
        if (line.len == 0) {
            return;
        }

        const a = line[0];
        const b = line[2];

        const opponent = try parseShape(a);

        switch (self.part) {
            1 => {
                const player = try parseShape(b);
                const result = play(opponent, player);
                self.total += scoreGame(player, result);
            },
            2 => {
                const result = try parseResult(b);
                const player = determinePlay(opponent, result);
                self.total += scoreGame(player, result);
            },
            else => return error.InvalidPart,
        }
    }

    pub fn finish(self: *const @This()) usize {
        return self.total;
    }
};

pub fn run(input: []const u8, comptime part: usize, a: Allocator) ![]u8 {
    var ctx = Context.init(part);
    try helpers.foreachLine(input, &ctx, Context.handleLine);

    return try std.fmt.allocPrint(a, "{d}", .{ctx.finish()});
}
