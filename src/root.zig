const std = @import("std");

pub fn WhileRange(comptime T: type) type {
    // Verify T is a numeric type
    comptime {
        switch (@typeInfo(T)) {
            .Int, .Float => {},
            else => @compileError("Range only supports numeric types"),
        }
    }

    const SignedT = switch (@typeInfo(T)) {
        .Int => |int_info| if (int_info.signedness == .unsigned)
            std.meta.Int(.signed, int_info.bits)
        else
            T,
        else => T,
    };

    return struct {
        start: T,
        end: T,
        step: SignedT,
        curr: T,
        //signed_step: SignedT,

        const Self = @This();

        pub fn init(start: T, end: T, inclusive: bool, step: SignedT) !Self {
            // Validate step isn't zero
            if (0 == step) return error.ZeroStep;
            var range_size: T = 0;
            var steps: T = 0; //@divFloor(@abs(end - start), @abs(step));
            var end_: T = end;
            if (start <= end) {
                if (0 > step) {
                    // empty range
                    end_ = start;
                } else {
                    range_size = (end - start);
                    if (comptime @typeInfo(T) == .Int) {
                        steps = @divFloor(range_size, @as(T, @intCast(step)));
                    } else {
                        steps = @divFloor(range_size, step);
                    }
                }
            } else {
                if (0 < step) {
                    // empty range
                    end_ = start;
                } else {
                    range_size = (start - end);
                    if (comptime @typeInfo(T) == .Int) {
                        steps = @divFloor(range_size, @as(T, @intCast(0 - step)));
                    } else {
                        steps = @divFloor(range_size, 0 - step);
                    }
                }
            }
            //std.debug.print("start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });

            if (comptime @typeInfo(T) == .Int) {
                end_ = @as(T, @intCast(@as(SignedT, @intCast(start)) + @as(SignedT, @intCast(steps)) * step));
            } else {
                end_ = start + steps * step;
            }

            var not_on_step = end_ != end;
            if (comptime @typeInfo(T) == .Float) {
                not_on_step = @abs(end_ - end) > @abs(step / 10);
                //std.debug.print("end_: {d} end: {d} step: {d} not_on_step: {}\n", .{ end_, end, step, not_on_step });
            }
            if ((0 < range_size) and (inclusive or not_on_step)) {
                if (comptime @typeInfo(T) == .Int) {
                    end_ = @as(T, @intCast(@as(SignedT, @intCast(end_)) + step));
                } else {
                    end_ = end_ + step;
                }
            }

            //std.debug.print("start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });

            return Self{
                .start = start,
                .end = end_,
                .step = step,
                .curr = start,
                //.signed_step = step,
            };
        }

        fn print_debug(s: *Self) void {
            std.debug.print("start: {d} end: {d} step: {d} curr: {d}\n", .{ s.start, s.end, s.step, s.curr });
        }

        pub fn next(self: *Self) ?T {
            if (comptime @typeInfo(T) == .Float) {
                //print_debug(self);
                const epsilon = self.step / 2.0;
                // Handle both forward and backward iteration
                const valid = if (self.step > 0)
                    self.curr < self.end - epsilon
                else
                    self.curr > self.end - epsilon;

                if (!valid) return null;
            } else {
                const valid = if (self.step > 0)
                    self.curr < self.end
                else
                    self.curr > self.end;

                if (!valid) return null;
            }

            const value = self.curr;
            if (comptime @typeInfo(T) == .Int) {
                self.curr = @as(T, @intCast(@as(SignedT, @intCast(self.curr)) + self.step));
            } else {
                self.curr = self.curr + self.step;
            }
            return value;
        }
    };
}

pub fn IndexedWhileRange(comptime T: type) type {
    return struct {
        range: WhileRange(T),
        index: usize,

        const SignedT = switch (@typeInfo(T)) {
            .Int => |int_info| if (int_info.signedness == .unsigned)
                std.meta.Int(.signed, int_info.bits)
            else
                T,
            else => T,
        };

        const Self = @This();

        pub fn init(start: T, end: T, inclusive: bool, step: SignedT) !Self {
            return Self{
                .range = try WhileRange(T).init(start, end, inclusive, step),
                .index = 0,
            };
        }

        pub fn next(self: *Self) ?struct { index: usize, value: T } {
            if (self.range.next()) |value| {
                const result = .{
                    .index = self.index,
                    .value = value,
                };
                self.index += 1;
                return result;
            }
            return null;
        }
    };
}

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

test "indexed while range" {
    var index: usize = 0;
    var range = try IndexedWhileRange(u8).init(10, 1, true, -1);
    std.debug.print("Indexed backward u8 while range [10, 1]:\n", .{});
    std.debug.print("(Index:Value)", .{});
    while (range.next()) |element| {
        try std.testing.expectEqual(index, element.index);
        index += 1;
        std.debug.print("({}:{})\n", .{ element.index, element.value });
    }
    std.debug.print("\n", .{});
}
