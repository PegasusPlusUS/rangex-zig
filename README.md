# RangeX

Zig 'for' loop can't use customized range, only 'while' loop flexible enough.
And 'for' loop can trace multiple ranges, so together with '0..' can be used as index, so dedicated indexed range only useful in 'while' loop.

```Shell
# Add dependent
git submodule add -f --name rangex https://github.com/PegasusPlusUS/rangex-zig.git src\\external\\while_rangex
```

```Zig
// Usage:
// in build.zig
pub fn build(b: *std.Build) void {
    //...
    //...
    //...

    // lib target
    const lib = b.addStaticLibrary(.{
        .name = "my_zig_lib",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    // add anonymous import to facilitate import in exe source files, if cross imported,
    // both should add anonymous import
    lib.root_module.addAnonymousImport("while_rangex", .{
        .root_source_file = b.path("src/external/while_rangex/src/root.zig"),
    });

    // exe target
    const exe = b.addExecutable(.{
        .name = "my_zig_executable",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // add anonymous import to facilitate import in exe source files, if cross imported,
    // both should add anonymous import
    exe.root_module.addAnonymousImport("while_rangex", .{
        .root_source_file = b.path("src/external/while_rangex/src/root.zig"),
    });
    exe.linkLibrary(lib_while_rangex);
}
```

```Zig
// Usage:
// in src/main.zig
// Use anonymous import instead, can only use one way, to avoid symbol redefinition.
// const while_rangex = @import("external/while_rangex/src/root.zig").WhileRange;
const while_rangex = @import("while_rangex").WhileRange;

fn main() !void {
    var sum:usize = 0;
    var accumulate_range = try while_rangex(usize).init(1, 100, true, 1);
    while (accumulate_range.next()) |n| {
        sum += n;
    }
    std.debug.print("Accumulate from {} to {} result in:{}", .{1, 100, sum});
}
```

```Zig
// Example:
// in src/external/while_rangex/src/root.zig
// main() and test cases in while_rangex library:
pub fn main() !void {
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

test "indexed while range" {
    var index :usize = 0;
    var range = try IndexedWhileRange(u8).init(10, 1, true, -1);
    std.debug.print("Indexed backward u8 while range [10, 1]:\n", .{});
    std.debug.print("(Index:Value)", .{});
    while (range.next()) |element| {
        try std.testing.expectEqual(index, element.index);
        index += 1;
        std.debug.print("({}:{})\n", .{element.index, element.value});
    }
    std.debug.print("\n", .{});
}

```
