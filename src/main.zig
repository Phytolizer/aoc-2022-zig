const std = @import("std");
const all_days = @import("all_days.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.detectLeaks();
    const a = gpa.allocator();

    const args = try std.process.argsAlloc(a);
    defer std.process.argsFree(a, args);

    if (args.len > 1) {
        const day = try std.fmt.parseInt(u8, args[1], 10);
        if (day > 0 and day <= all_days.IMPLEMENTED_DAYS) {
            try all_days.run_day(a, day);
        } else {
            std.debug.print("Day {d} is not implemented yet\n", .{day});
            std.process.exit(1);
        }
    }
}
