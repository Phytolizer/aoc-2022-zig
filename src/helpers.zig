const std = @import("std");

pub const RunError = error{} ||
    std.fmt.ParseIntError ||
    std.fmt.AllocPrintError;

pub fn foreachLine(input: []const u8, context: anytype, handler: anytype) RunError!void {
    // check handler is a fn
    const ty = @typeInfo(@TypeOf(handler));
    switch (ty) {
        .Fn => {},
        else => @compileError("handler must be a function"),
    }
    switch (@typeInfo(ty.Fn.return_type.?)) {
        .ErrorUnion => {},
        else => @compileError("handler must return an error union"),
    }
    if (ty.Fn.args.len != 2) {
        @compileError("handler must take two arguments");
    }
    if (ty.Fn.args[0].arg_type.? != @TypeOf(context)) {
        @compileError("handler's first argument must be the same type as context");
    }
    if (ty.Fn.args[1].arg_type.? != []const u8) {
        @compileError("handler's second argument must be []const u8");
    }
    var i: usize = 0;
    while (i < input.len) {
        const end = std.mem.indexOfScalarPos(u8, input, i, '\n') orelse break;
        defer i = end + 1;

        const cr = if (end > i and input[end - 1] == '\r')
            end - 1
        else
            end;
        try handler(context, input[i..cr]);
    }
}
