const std = @import("std");
const day = @import("day_interface.zig");

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_state.deinit() == .ok);
    const gpa = gpa_state.allocator();

    std.log.info("Solving examples...", .{});

    inline for (day.days, day.examples, 1..) |d, x, num| {
        inline for (1..3) |part| {
            const text = try d.Solver(part)(gpa, x);
            std.log.info("Day {d:0>2}, part {d} = {s}", .{ num, part, text });
            gpa.free(text);
        }
    }
}
