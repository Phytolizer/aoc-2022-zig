const std = @import("std");
const Allocator = std.mem.Allocator;
const foreachLine = @import("helpers.zig").foreachLine;

fn Context(comptime part: usize) type {
    const BestArray = if (part == 1) [1]usize else [3]usize;
    const Bests = struct {
        array: BestArray,

        pub fn init() @This() {
            return .{
                .array = if (part == 1) [_]usize{0} else [_]usize{ 0, 0, 0 },
            };
        }

        pub fn add(self: *@This(), value: usize) void {
            var min = &self.array[0];
            for (self.array[1..]) |*e| {
                if (min.* > e.*) {
                    min = e;
                }
            }

            if (value < min.*) {
                return;
            }

            min.* = value;
        }
    };
    return struct {
        total: usize = 0,
        bests: Bests = undefined,

        pub fn handleLine(self: *@This(), line: []const u8) !void {
            if (line.len == 0) {
                self.bests.add(self.total);
                self.total = 0;
                return;
            }

            const num = try std.fmt.parseInt(usize, line, 10);
            self.total += num;
        }

        pub fn finish(self: *@This()) usize {
            self.bests.add(self.total);
            var total: usize = 0;
            for (self.bests.array) |e| {
                total += e;
            }
            return total;
        }
    };
}

pub fn run(input: []const u8, comptime part: usize, a: Allocator) ![]u8 {
    var context = Context(part){};
    try foreachLine(input, &context, Context(part).handleLine);

    return try std.fmt.allocPrint(a, "{d}", .{context.finish()});
}
