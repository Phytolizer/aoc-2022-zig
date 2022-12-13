const std = @import("std");
const helpers = @import("helpers.zig");

const Day = struct {
    Module: type,
    dayNum: usize,

    pub fn init(comptime Module: type, comptime dayNum: usize) @This() {
        return .{
            .Module = Module,
            .dayNum = dayNum,
        };
    }
};

const dayModules = [_]Day{
    Day.init(@import("dec01.zig"), 1),
    Day.init(@import("dec02.zig"), 2),
    Day.init(@import("dec03.zig"), 3),
    Day.init(@import("dec04.zig"), 4),
    Day.init(@import("dec05.zig"), 5),
    Day.init(@import("dec06.zig"), 6),
};

const Input = struct {
    simple: []const u8,
    full: []const u8,
};

const inputKinds = [_][]const u8{ "simple", "full" };
const parts = [_]usize{ 1, 2 };

const inputs = getInputs: {
    var tmpInputs: [dayModules.len]Input = undefined;
    for (dayModules) |dayModule, i| {
        for (inputKinds) |inputKind| {
            const input = std.fmt.comptimePrint("input/{d:0>2}.{s}.txt", .{
                dayModule.dayNum,
                inputKind,
            });
            @field(tmpInputs[i], inputKind) = @embedFile(input);
        }
    }
    break :getInputs tmpInputs;
};

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
                inline for (dayModules) |day, i| {
                    inline for (parts) |part| {
                        const result = try day.Module.runner(part)(inputs[i].full, a);
                        a.free(result);
                    }
                }
            }
        },
        2 => {
            const day = try std.fmt.parseInt(u8, args[1], 10);
            const runners: [2]*const helpers.DayRunner = findDay: {
                inline for (dayModules) |dayMod| {
                    if (dayMod.dayNum == day) {
                        var runners: [2]*const helpers.DayRunner = undefined;
                        inline for (parts) |part| {
                            runners[part - 1] = dayMod.Module.runner(part);
                        }
                        break :findDay runners;
                    }
                }
                std.debug.print("Day {d} is not implemented yet\n", .{day});
                std.process.exit(1);
            };
            inline for (runners) |runner, i| {
                var timer = try std.time.Timer.start();
                const RUNS = 10000;
                var run: usize = 0;
                while (run < RUNS) : (run += 1) {
                    const result = try runner(inputs[day - 1].full, a);
                    a.free(result);
                }
                const elapsed = timer.read();
                std.debug.print("Day {d:0>2}p{d}: {d:8.3}μs/run ({d} runs)\n", .{
                    day,
                    i + 1,
                    @intToFloat(f64, elapsed / RUNS) / 1000.0,
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

test {
    inline for (dayModules) |dayModule, i| {
        inline for (parts) |part| {
            inline for (inputKinds) |inputKind| {
                const runner = dayModule.Module.runner(part);
                const result = try runner(@field(inputs[i], inputKind), std.testing.allocator);
                defer std.testing.allocator.free(result);
                const expected = @field(dayModule.Module.expected[part - 1], inputKind);
                try std.testing.expectEqualStrings(expected, result);
            }
        }
    }
}
