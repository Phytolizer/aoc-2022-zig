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

test "examples" {
    const gpa = std.testing.allocator;
    const DaySpec = struct { day: usize, part: usize };
    var failures = std.ArrayList(DaySpec).init(gpa);
    defer failures.deinit();
    inline for (day.days, day.examples, day.example_solutions, 1..) |d, x, solutions, daynum| {
        inline for (solutions, 1..) |solution, part| {
            const text = try d.Solver(part)(gpa, x);
            defer gpa.free(text);
            if (!std.mem.eql(u8, solution, text)) {
                std.log.err(
                    "day {d}, part {d}: expected '{s}', got '{s}'",
                    .{ daynum, part, solution, text },
                );
                try failures.append(.{ .day = daynum, .part = part });
            }
        }
    }

    if (failures.items.len > 0) {
        std.log.err("failed:", .{});
        for (failures.items) |fail| {
            std.log.err("day {d}, part {d}", .{ fail.day, fail.part });
        }
        return error.Fail;
    }
}
