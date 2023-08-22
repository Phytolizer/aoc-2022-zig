const std = @import("std");
const helpers = @import("helpers.zig");
const days = @import("days.zig");

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
                inline for (days.dayModules, 0..) |day, i| {
                    inline for (days.parts) |part| {
                        const result = try day.Module.runner(part)(days.inputs[i].full, a);
                        a.free(result);
                    }
                }
            }
        },
        2 => {
            const day = try std.fmt.parseInt(u8, args[1], 10);
            const runners: [2]*const helpers.DayRunner = findDay: {
                inline for (days.dayModules) |dayMod| {
                    if (dayMod.dayNum == day) {
                        var runners: [2]*const helpers.DayRunner = undefined;
                        inline for (days.parts) |part| {
                            runners[part - 1] = dayMod.Module.runner(part);
                        }
                        break :findDay runners;
                    }
                }
                std.debug.print("Day {d} is not implemented yet\n", .{day});
                std.process.exit(1);
            };
            inline for (runners, 0..) |runner, i| {
                var timer = try std.time.Timer.start();
                const RUNS = 10000;
                var run: usize = 0;
                while (run < RUNS) : (run += 1) {
                    const result = try runner(days.inputs[day - 1].full, a);
                    a.free(result);
                }
                const elapsed = timer.read();
                std.debug.print("Day {d:0>2}p{d}: {d:8.3}μs/run ({d} runs)\n", .{
                    day,
                    i + 1,
                    @as(f64, @floatFromInt(elapsed / RUNS)) / 1000.0,
                    RUNS,
                });
            }
        },
        else => {
            std.debug.print("Usage: {s} [day]\n", .{args[0]});
            std.process.exit(1);
        },
    }
}
