const std = @import("std");
const days = @import("days.zig");
const Allocator = std.mem.Allocator;

pub fn testCase(
    comptime dayModule: days.Day,
    comptime part: usize,
    comptime inputKind: []const u8,
    comptime input: days.Input,
    a: Allocator,
) !void {
    const runner = dayModule.Module.runner(part);
    const result = try runner(@field(input, inputKind), a);
    defer a.free(result);
    const expected = @field(dayModule.Module.expected[part - 1], inputKind);
    try std.testing.expectEqualStrings(expected, result);
}

pub fn main() !void {
    var tests: usize = 0;
    var failures: usize = 0;
    var test_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = test_gpa.allocator();
    inline for (days.dayModules, 0..) |dayModule, i| {
        inline for (days.parts) |part| {
            inline for (days.inputKinds) |inputKind| {
                tests += 1;
                const testDescription = std.fmt.comptimePrint(
                    "day {d:0>2}, part {d}, {s} input",
                    .{ dayModule.dayNum, part, inputKind },
                );
                testCase(dayModule, part, inputKind, days.inputs[i], a) catch {
                    std.debug.print("Failed on {s}\n", .{testDescription});
                    if (@errorReturnTrace()) |trace| {
                        trace.format("", .{}, std.io.getStdErr().writer()) catch unreachable;
                    }
                    failures += 1;
                };
                if (test_gpa.detectLeaks()) {
                    std.debug.print("Leaked memory on {s}\n", .{testDescription});
                    failures += 1;
                }
            }
        }
    }

    if (failures > 0) {
        std.debug.print("Failed {d} tests\n", .{failures});
        std.process.exit(1);
    }
    std.debug.print("Passed {d} tests\n", .{tests});
}
