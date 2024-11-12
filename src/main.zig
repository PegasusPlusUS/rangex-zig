const std = @import("std");

const WhileRange = @import("root.zig").WhileRange;
const lib_main = @import("root.zig").lib_main;
pub fn main() !void {
    // Integer range (forward)
    try lib_main();
}

test "test_exe_main" {
    try main();
}
