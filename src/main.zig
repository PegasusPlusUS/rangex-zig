const std = @import("std");

const WhileRange = @import("root.zig").WhileRange;
//const lib_main = @import("root.zig").main;

pub fn main() !void {
    std.debug.print("{s}\n", .{"Hello, world!"});
    std.debug.print("{s}\n", .{"This lib tested extensively for up to i128/u128"});
}

test "test_exe_main" {
    std.debug.print("Running tests in src/main.zig \"main\"\n", .{});

    try main();
}

test "test_lib_main_within_exe" {
    //try lib_main();
}
