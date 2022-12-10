pub const Expected = struct {
    simple: []const u8,
    full: []const u8,
};

pub const dec01 = &[_]Expected{
    .{ .simple = "24000", .full = "69289" },
    .{ .simple = "45000", .full = "205615" },
};

pub const dec02 = &[_]Expected{
    .{ .simple = "15", .full = "14531" },
    .{ .simple = "12", .full = "11258" },
};

pub const dec03 = &[_]Expected{
    .{ .simple = "157", .full = "7766" },
    .{ .simple = "70", .full = "2415" },
};

pub const dec04 = &[_]Expected{
    .{ .simple = "2", .full = "433" },
    .{ .simple = "4", .full = "852" },
};
