const std = @import("std");

pub fn foreachLine(input: []const u8, comptime T: type, context: *T) !void {
    var i: usize = 0;
    while (i < input.len) {
        const end = std.mem.indexOfScalarPos(u8, input, i, '\n') orelse break;
        defer i = end + 1;

        try context.handleLine(input[i..end]);
    }
}
