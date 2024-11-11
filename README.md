Zig for loop can't use customized range, only while loop flexible enough.

```Zig
pub fn main() !void {
    // Integer range (forward)
    var range1 = try Range(i32).init(0, 10, 2);
    std.debug.print("Forward int range by 2:\n", .{});
    while (range1.next()) |value| {
        std.debug.print("{} ", .{value});
    }
    std.debug.print("\n\n", .{});

    // Integer range (backward)
    var range2 = try Range(i32).init(10, 0, -3);
    std.debug.print("Backward int range by -3:\n", .{});
    while (range2.next()) |value| {
        std.debug.print("{} ", .{value});
    }
    std.debug.print("\n\n", .{});

    // Float range
    var range3 = try Range(f32).init(0.0, 1.0, 0.2);
    std.debug.print("Float range by 0.2:\n", .{});
    while (range3.next()) |value| {
        std.debug.print("{d:.1} ", .{value});
    }
    std.debug.print("\n", .{});
}
```
