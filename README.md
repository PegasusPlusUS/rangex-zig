# RangeX

Zig for loop can't use customized range, only while loop flexible enough.

```Zig
pub fn lib_main() !void {
    // Integer range (forward)
    var range1 = try WhileRange(i32).init(0, 10, false, 2);
    std.debug.print("Forward exclusive int range [0, 10) by 2:\n", .{});
    while (range1.next()) |value| {
        std.debug.print("{} ", .{value});
    }
    std.debug.print("\n\n", .{});

    // Integer range (backward)
    var range2 = try WhileRange(i32).init(10, 0, false, -3);
    std.debug.print("Backward exclusive int range [10, 0) by -3:\n", .{});
    while (range2.next()) |value| {
        std.debug.print("{} ", .{value});
    }
    std.debug.print("\n\n", .{});

    // Float range
    var range3 = try WhileRange(f32).init(0.0, 1.0, false, 0.2);
    std.debug.print("Float exclusive range [0.0, 1.0) by 0.2:\n", .{});
    while (range3.next()) |value| {
        std.debug.print("{d:.1} ", .{value});
    }
    std.debug.print("\n\n", .{});

    var range4 = try WhileRange(f32).init(1.0, 0.0, false, -0.2);
    std.debug.print("Backward float exclusive range [1.0, 0.0) by -0.2:\n", .{});
    while (range4.next()) |value| {
        std.debug.print("{d:.1} ", .{value});
    }
    std.debug.print("\n", .{});
}

test "test_lib_main" {
    std.debug.print("Running tests in src/root.zig \"main\"\n", .{});

    try lib_main();
}

test "std u8 start stop exclusive step is 1" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(1, 101, false, 1);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, 5050);
}

test "std u8 start stop backward exclusive step is -1" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(100, 0, false, -1);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, 5050);
}

test "std u8 start stop backward inclusive step is -1" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(100, 1, true, -1);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, 5050);
}

test "std u8 start stop inclusive step is 1" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(1, 100, true, 1);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, 5050);
}

test "std u8 start stop exclusive step is 2" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(1, 101, false, 2);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, (1 + 99) * 50 / 2);
}

test "std u8 start stop inclusive step is 2" {
    // Integer range (forward)
    var s: u16 = 0;
    var range1 = try WhileRange(u8).init(1, 101, true, 2);
    while (range1.next()) |value| {
        s += value;
    }
    try std.testing.expectEqual(s, (1 + 101) * 51 / 2);
}

test "std u8 start stop ex/inclusive step is 2 stop not on step" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 100, false, 2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 100, true, 2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_e, (1 + 99) * 50 / 2);
    try std.testing.expectEqual(s_i, s_e);
}

test "std u8 start stop backward exclusive step is -2 stop not on step" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(100, 1, false, -2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(100, 1, true, -2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_e, (100 + 2) * 50 / 2);
    try std.testing.expectEqual(s_i, s_e);
}

test "std u8 start stop ex/inclusive empty range" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 0, false, 2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 0, true, 2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 0);
}

test "std i8 start stop ex/inclusive empty range" {
    // Integer range (forward)
    var s_e: i16 = 0;
    var range_e = try WhileRange(i8).init(0, 1, false, -2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: i16 = 0;
    var range_i = try WhileRange(i8).init(0, 1, true, -2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 0);
}

test "std f32 start stop ex/inclusive step is 0.2" {
    var s_e: f32 = 0;
    var range_e = try WhileRange(f32).init(0.0, 1.0, false, 0.2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, (0.0 + 0.8) * 5 / 2);

    var s_i: f32 = 0;
    var range_i = try WhileRange(f32).init(0.0, 1.0, true, 0.2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, (0.0 + 1.0) * 6 / 2);
}

test "std f32 start stop backward exclusive step is -0.2" {
    var s_e: f32 = 0;
    var range_e = try WhileRange(f32).init(0.8, -0.2, false, -0.2);
    while (range_e.next()) |value| {
        //std.debug.print("{d:.1} ", .{value});
        s_e += value;
    }

    // Use approxEqAbs or approxEqRel for float comparison
    try std.testing.expectApproxEqAbs(s_e, (0.8 + 0.0) * 5 / 2, 1e-6);

    var s_i: f32 = 0;
    var range_i = try WhileRange(f32).init(1.0, 0.0, true, -0.2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectApproxEqAbs(s_i, (1.0 + 0.0) * 6 / 2, 1e-6);
}
```
