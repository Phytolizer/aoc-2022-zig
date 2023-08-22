const std = @import("std");

pub const Day = struct {
    Module: type,
    dayNum: usize,

    pub fn init(comptime Module: type, comptime dayNum: usize) @This() {
        return .{
            .Module = Module,
            .dayNum = dayNum,
        };
    }
};

pub const dayModules = [_]Day{
    Day.init(@import("dec01.zig"), 1),
    Day.init(@import("dec02.zig"), 2),
    Day.init(@import("dec03.zig"), 3),
    Day.init(@import("dec04.zig"), 4),
    Day.init(@import("dec05.zig"), 5),
    Day.init(@import("dec06.zig"), 6),
};

pub const Input = struct {
    simple: []const u8,
    full: []const u8,
};

pub const inputKinds = [_][]const u8{ "simple", "full" };
pub const parts = [_]usize{ 1, 2 };

pub const inputs = getInputs: {
    var tmpInputs: [dayModules.len]Input = undefined;
    for (dayModules, 0..) |dayModule, i| {
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
