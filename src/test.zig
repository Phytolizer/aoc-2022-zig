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
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    inline for (days.dayModules) |dayModule, i| {
        inline for (days.parts) |part| {
            inline for (days.inputKinds) |inputKind| {
                tests += 1;
                testCase(dayModule, part, inputKind, days.inputs[i], a) catch {
                    std.debug.print("Failed on day {d:0>2}, part {d}, {s} input\n", .{ i + 1, part, inputKind });
                    if (@errorReturnTrace()) |trace| {
                        trace.format("", .{}, std.io.getStdErr().writer()) catch unreachable;
                    }
                    failures += 1;
                };
            }
        }
    }

    if (failures > 0) {
        std.debug.print("Failed {d} tests\n", .{failures});
        std.process.exit(1);
    }
    std.debug.print("Passed {d} tests\n", .{tests});
}
