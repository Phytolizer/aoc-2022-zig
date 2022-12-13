const std = @import("std");
const Allocator = std.mem.Allocator;
const helpers = @import("helpers.zig");
const Expected = @import("expected.zig").Expected;

pub fn runner(comptime part: usize) fn ([]const u8, Allocator) helpers.RunError![]u8 {
    return struct {
        const history_len = if (part == 1) 4 else 14;
        pub fn run(input: []const u8, a: Allocator) ![]u8 {
            var seen: [26]usize = undefined;
            std.mem.set(usize, &seen, 0);

            var buf = try a.alloc(u8, history_len);
            defer a.free(buf);

            var rb = helpers.RingBuffer(u8).init(buf);

            for (input) |c, i| {
                if (c == '\r' or c == '\n') {
                    break;
                }

                seen[c - 'a'] += 1;
                if (rb.push(c)) |old| {
                    seen[old - 'a'] -= 1;
                    checkDone: {
                        for (rb.buffer) |it| {
                            if (seen[it - 'a'] > 1) {
                                break :checkDone;
                            }
                        }

                        return std.fmt.allocPrint(a, "{d}", .{i + 1});
                    }
                }
            }

            unreachable;
        }
    }.run;
}

pub const expected = [_]Expected{
    .{ .simple = "11", .full = "1080" },
    .{ .simple = "26", .full = "3645" },
};
