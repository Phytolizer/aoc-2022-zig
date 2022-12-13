const std = @import("std");
const Allocator = std.mem.Allocator;
const helpers = @import("helpers.zig");
const Expected = @import("expected.zig").Expected;

const Context = struct {
    a: Allocator,
    part: usize,
    parsing_crates: bool = true,
    raw_crates: Crates,
    moves: std.ArrayList(Move),
    stacks: Crates,

    const Crates = std.ArrayList(std.ArrayList(u8));

    const Move = struct {
        num: usize,
        source: usize,
        dest: usize,
    };

    pub fn init(a: Allocator, part: usize) @This() {
        return .{
            .a = a,
            .part = part,
            .raw_crates = Crates.init(a),
            .moves = std.ArrayList(Move).init(a),
            .stacks = Crates.init(a),
        };
    }

    fn deinit(self: *@This()) void {
        for (self.raw_crates.items) |*row| {
            row.deinit();
        }
        self.raw_crates.deinit();
        self.moves.deinit();
        for (self.stacks.items) |*stack| {
            stack.deinit();
        }
        self.stacks.deinit();
    }

    pub fn handleLine(self: *@This(), line: []const u8) !void {
        if (line.len == 0) {
            return;
        }

        if (self.parsing_crates) {
            var i: usize = 1;
            if (line[i] == '1') {
                self.parsing_crates = false;
                return;
            }
            try self.raw_crates.append(std.ArrayList(u8).init(self.a));
            const row = &self.raw_crates.items[self.raw_crates.items.len - 1];
            while (i < line.len) : (i += 4) {
                const crate = line[i];
                try row.append(crate);
            }
        } else {
            // move <x> from <y> to <z>
            // 01234^  ^12345^  ^123^
            var start: usize = 5;
            var end: usize = std.mem.indexOfScalarPos(u8, line, start, ' ').?;
            const num = try std.fmt.parseInt(usize, line[start..end], 10);
            start = end + 6;
            end = std.mem.indexOfScalarPos(u8, line, start, ' ').?;
            const source = try std.fmt.parseInt(usize, line[start..end], 10);
            start = end + 4;
            const dest = try std.fmt.parseInt(usize, line[start..], 10);
            try self.moves.append(.{ .num = num, .source = source, .dest = dest });
        }
    }

    fn transpose_crates(self: *@This()) !void {
        for (self.raw_crates.items) |raw| {
            for (raw.items) |crate, i| {
                if (i >= self.stacks.items.len) {
                    try self.stacks.append(std.ArrayList(u8).init(self.a));
                }

                try self.stacks.items[i].append(crate);
            }
        }

        for (self.stacks.items) |*stack| {
            std.mem.reverse(u8, stack.items);
            var i: usize = stack.items.len;
            while (i > 0) : (i -= 1) {
                if (stack.items[i - 1] != ' ') {
                    break;
                }
            }
            stack.shrinkRetainingCapacity(i);
        }
    }

    pub fn finish(self: *@This()) ![]u8 {
        try self.transpose_crates();
        for (self.moves.items) |move| {
            const source = &self.stacks.items[move.source - 1];
            const dest = &self.stacks.items[move.dest - 1];
            const crates = source.items[source.items.len - move.num ..];
            if (self.part == 1) {
                std.mem.reverse(u8, crates);
            }
            try dest.appendSlice(crates);
            source.shrinkRetainingCapacity(source.items.len - move.num);
        }
        var buf = try self.a.alloc(u8, self.stacks.items.len);
        for (self.stacks.items) |stack, i| {
            buf[i] = stack.items[stack.items.len - 1];
        }
        self.deinit();
        return buf;
    }
};

pub fn runner(comptime part: usize) helpers.DayRunner {
    return struct {
        pub fn run(input: []const u8, a: Allocator) ![]u8 {
            var context = Context.init(a, part);
            try helpers.foreachLine(input, &context, Context.handleLine);

            return try context.finish();
        }
    }.run;
}

pub const expected = [_]Expected{
    .{ .simple = "CMZ", .full = "QMBMJDFTD" },
    .{ .simple = "MCD", .full = "NBTVTJNFJ" },
};
