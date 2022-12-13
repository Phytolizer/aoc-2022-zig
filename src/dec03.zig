const std = @import("std");
const Allocator = std.mem.Allocator;
const helpers = @import("helpers.zig");
const Expected = @import("expected.zig").Expected;

fn Context(comptime part: usize) type {
    const AlphaSet = struct {
        inner: std.StaticBitSet(52),

        pub fn init() @This() {
            return .{ .inner = std.StaticBitSet(52).initEmpty() };
        }

        pub fn addAll(self: *@This(), chars: []const u8) void {
            for (chars) |c| {
                if (c >= 'a' and c <= 'z') {
                    self.inner.set(c - 'a');
                } else if (c >= 'A' and c <= 'Z') {
                    self.inner.set(c - 'A' + 26);
                }
            }
        }

        pub fn intersect(self: *@This(), other: @This()) void {
            self.inner.setIntersection(other.inner);
        }

        pub fn get(self: @This()) usize {
            return self.inner.findFirstSet().?;
        }
    };

    return switch (part) {
        1 => struct {
            total: usize = 0,

            pub fn handleLine(self: *@This(), line: []const u8) !void {
                const middle = line.len / 2;

                var left_set = AlphaSet.init();
                left_set.addAll(line[0..middle]);
                var right_set = AlphaSet.init();
                right_set.addAll(line[middle..]);
                left_set.intersect(right_set);
                self.total += left_set.get() + 1;
            }

            pub fn finish(self: @This()) usize {
                return self.total;
            }
        },
        2 => struct {
            total: usize = 0,
            group_idx: usize = 0,
            groups: [3]AlphaSet = undefined,

            pub fn handleLine(self: *@This(), line: []const u8) !void {
                if (line.len == 0) {
                    return;
                }

                self.groups[self.group_idx] = AlphaSet.init();
                self.groups[self.group_idx].addAll(line);
                self.group_idx += 1;
                if (self.group_idx == 3) {
                    self.groups[0].intersect(self.groups[1]);
                    self.groups[0].intersect(self.groups[2]);
                    self.total += self.groups[0].get() + 1;
                    self.group_idx = 0;
                }
            }

            pub fn finish(self: @This()) usize {
                return self.total;
            }
        },
        else => @compileError("invalid part"),
    };
}

pub fn runner(comptime part: usize) helpers.DayRunner {
    return struct {
        pub fn run(input: []const u8, a: Allocator) ![]u8 {
            var ctx = Context(part){};
            try helpers.foreachLine(input, &ctx, Context(part).handleLine);

            return try std.fmt.allocPrint(a, "{d}", .{ctx.finish()});
        }
    }.run;
}

pub const expected = [_]Expected{
    .{ .simple = "157", .full = "7766" },
    .{ .simple = "70", .full = "2415" },
};
