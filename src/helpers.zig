const std = @import("std");

pub fn foreachLine(input: []const u8, comptime T: type, context: *T) !void {
    var i: usize = 0;
    while (i < input.len) {
        const end = std.mem.indexOfScalarPos(u8, input, i, '\n') orelse break;
        defer i = end + 1;

        const cr = if (end > i and input[end - 1] == '\r')
            end - 1
        else
            end;
        try context.handleLine(input[i..cr]);
    }
}
