const std = @import("std");

pub fn lines(text: []const u8) std.mem.SplitIterator(u8, .sequence) {
    return if (std.mem.indexOfScalar(u8, text, '\r') != null)
        std.mem.splitSequence(u8, text, "\r\n")
    else
        std.mem.splitSequence(u8, text, "\n");
}
