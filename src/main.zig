const std = @import("std");
const all_days = @import("all_days.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.detectLeaks();
    const a = gpa.allocator();

    const args = try std.process.argsAlloc(a);
    defer std.process.argsFree(a, args);

    switch (args.len) {
        1 => {
            const RUNS = 10;
            var run: usize = 0;
            while (run < RUNS) : (run += 1) {
                var day: usize = 1;
                while (day <= all_days.IMPLEMENTED_DAYS) : (day += 1) {
                    try all_days.run_day(a, day, null);
                }
            }
        },
        2 => {
            const day = try std.fmt.parseInt(u8, args[1], 10);
            if (day > 0 and day <= all_days.IMPLEMENTED_DAYS) {
                inline for ([_]usize{ 1, 2 }) |part| {
                    var timer = try std.time.Timer.start();
                    const RUNS = 10000;
                    var run: usize = 0;
                    while (run < RUNS) : (run += 1) {
                        try all_days.run_day(a, day, part);
                    }
                    const elapsed = timer.read();
                    std.debug.print("Day {d:0>2}p{d}: {d:8.3}μs/run ({d} runs)\n", .{
                        day,
                        part,
                        @intToFloat(f64, elapsed / RUNS) / 1000.0,
                        RUNS,
                    });
                }
            } else {
                std.debug.print("Day {d} is not implemented yet\n", .{day});
                std.process.exit(1);
            }
        },
        else => {
            std.debug.print("Usage: {s} [day]\n", .{args[0]});
            std.process.exit(1);
        },
    }
}
