const std = @import("std");
const Allocator = std.mem.Allocator;
const helpers = @import("helpers.zig");
const Expected = @import("expected.zig").Expected;

const Context = struct {
    total: usize = 0,
    part: usize,

    const Range = struct {
        min: usize,
        max: usize,

        pub fn intersects(self: @This(), other: @This()) bool {
            return self.min <= other.max and other.min <= self.max;
        }

        pub fn contains(self: @This(), other: @This()) bool {
            return self.min <= other.min and other.max <= self.max;
        }
    };

    pub fn init(comptime part: usize) @This() {
        return .{ .part = part };
    }

    pub fn handleLine(self: *@This(), line: []const u8) !void {
        var end = std.mem.indexOfScalar(u8, line, '-').?;
        const min1 = try std.fmt.parseInt(usize, line[0..end], 10);
        var start = end + 1;
        end = std.mem.indexOfScalarPos(u8, line, start, ',').?;
        const max1 = try std.fmt.parseInt(usize, line[start..end], 10);
        start = end + 1;
        end = std.mem.indexOfScalar(u8, line[start..], '-').?;
        const min2 = try std.fmt.parseInt(usize, line[start .. start + end], 10);
        start += end + 1;
        const max2 = try std.fmt.parseInt(usize, line[start..], 10);

        const range1 = Range{ .min = min1, .max = max1 };
        const range2 = Range{ .min = min2, .max = max2 };

        self.total += @intFromBool(switch (self.part) {
            1 => range1.contains(range2) or range2.contains(range1),
            2 => range1.intersects(range2),
            else => unreachable,
        });
    }

    pub fn finish(self: *@This()) usize {
        return self.total;
    }
};

pub fn runner(comptime part: usize) helpers.DayRunner {
    return struct {
        pub fn run(input: []const u8, a: Allocator) ![]u8 {
            var context = Context.init(part);
            try helpers.foreachLine(input, &context, Context.handleLine);

            return try std.fmt.allocPrint(a, "{d}", .{context.finish()});
        }
    }.run;
}

pub const expected = [_]Expected{
    .{ .simple = "2", .full = "433" },
    .{ .simple = "4", .full = "852" },
};
