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

    const UnsignedT = switch (@typeInfo(T)) {
        .Int => |int_info| if (int_info.signedness == .signed)
            std.meta.Int(.unsigned, int_info.bits)
        else
            T,
        else => T,
    };

    const ExtendedSignedT = switch (@typeInfo(T)) {
        .Int => |int_info| std.meta.Int(.signed, 2 * int_info.bits),
        else => T,
    };

    return struct {
        start: T,
        end: T,
        step: SignedT, // so step can't be over (T.max - T.min) / 2, to do this, need countup()/countdown() seperate interfaces
        curr: T,
        negative_range: bool,
        inclusive_or_not_on_step: bool,

        const Self = @This();
        const debug_print = false;

        pub fn init(start: T, end: T, inclusive: bool, step: SignedT) !Self {
            // Validate step isn't zero
            if (0 == step) return error.ZeroStep;

            if (debug_print) {
                std.debug.print("Original start: {d} end: {d} step: {d} inclusive:{}\n", .{ start, end, step, inclusive });
            }

            var negative_range = false;
            var range_size: UnsignedT = 0;
            var steps: UnsignedT = 0; //@divFloor(@abs(end - start), @abs(step));
            var end_: T = end;
            var not_on_step = false;

            if (start < end) {
                if (0 > step) {
                    // negative range
                    negative_range = true;
                } else {
                    if (comptime @typeInfo(T) == .Int) {
                        const result = @subWithOverflow(end, start);
                        range_size = @as(UnsignedT, @bitCast(result[0]));
                        steps = @divFloor(range_size, @as(UnsignedT, @intCast(step)));
                    } else {
                        range_size = end - start;
                        steps = @divFloor(range_size, step);
                    }
                }
            } else if (start > end) {
                if (0 < step) {
                    negative_range = true;
                } else {
                    if (comptime @typeInfo(T) == .Int) {
                        const result = @subWithOverflow(@as(UnsignedT, @bitCast(start)), @as(UnsignedT, @bitCast(end)));
                        range_size = result[0];
                        steps = @divFloor(range_size, @as(UnsignedT, @intCast(0 - step)));
                    } else {
                        range_size = start - end;
                        steps = @divFloor(range_size, 0 - step);
                    }
                }
            }

            if (negative_range) {
                end_ = start;
            } else {
                if (debug_print) {
                    std.debug.print("After range_size, start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });
                }
                if (0 != range_size) {
                    if (comptime @typeInfo(T) == .Int) {
                        if (step < 0) {
                            //std.debug.print("start:{} end:{} range_size:{} steps:{} step:{}\n", .{ start, end, range_size, steps, step });
                        }
                        // May overflow, need carefully test and cast to extended signedT ( u8 -> i16 )
                        const result = @as(ExtendedSignedT, start) + @as(ExtendedSignedT, steps) * @as(ExtendedSignedT, step);
                        //std.debug.print("calculate start - steps * abs(step) is: {}\n", .{result});
                        end_ = @as(T, @intCast(result));
                    } else {
                        end_ = start + steps * step;
                    }
                }

                if (debug_print) {
                    std.debug.print("After start + steps * step, start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });
                }

                not_on_step = end_ != end;
                if (comptime @typeInfo(T) == .Float) {
                    not_on_step = @abs(end_ - end) > @abs(step / 10);
                    if (debug_print) {
                        std.debug.print("end_: {d} end: {d} step: {d} not_on_step: {}\n", .{ end_, end, step, not_on_step });
                    }
                }

                if (inclusive or (0 < range_size and not_on_step)) {
                    if (comptime @typeInfo(T) == .Int) {
                        const result = @addWithOverflow(end_, @as(T, @bitCast(step)));
                        end_ = result[0];
                    } else {
                        end_ = end_ + step;
                    }

                    if (debug_print) {
                        std.debug.print("Adjust for inclusive or not_on_step, start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });
                    }
                }
            }

            if (debug_print) {
                std.debug.print("Finally, start: {d} end: {d} step: {d} range_size: {d} end_: {d}\n", .{ start, end, step, range_size, end_ });
            }

            return Self{
                .start = start,
                .end = end_,
                .step = step,
                .curr = start,
                .negative_range = negative_range,
                .inclusive_or_not_on_step = inclusive or not_on_step,
            };
        }

        fn print_debug(s: *Self) void {
            std.debug.print("start: {d} end: {d} step: {d} curr: {d}\n", .{ s.start, s.end, s.step, s.curr });
        }

        pub fn next(self: *Self) ?T {
            if (self.negative_range) {
                return null;
            }

            var valid = false;
            if (comptime @typeInfo(T) == .Float) {
                const epsilon = @abs(self.step / 2.0);
                // avoid overflow
                if (self.curr > self.end) {
                    valid = epsilon < self.curr - self.end;
                } else {
                    valid = epsilon < self.end - self.curr;
                }
            } else {
                valid = self.curr != self.end;
            }

            if (debug_print) {
                if ((self.curr > self.end and (@as(ExtendedSignedT, self.curr) - @as(ExtendedSignedT, self.end)) < 2) or
                    (self.curr < self.end and (@as(ExtendedSignedT, self.end) - @as(ExtendedSignedT, self.curr)) < 2))
                {
                    std.debug.print("current: {} end: {} step: {}\n", .{ self.curr, self.end, self.step });
                }
            }

            if (!self.inclusive_or_not_on_step) {
                if (!valid) {
                    return null;
                }
            } else {
                self.inclusive_or_not_on_step = false;
            }

            const value = self.curr;
            if (comptime @typeInfo(T) == .Int) {
                const result = @addWithOverflow(@as(SignedT, @bitCast(self.curr)), self.step);
                self.curr = @as(T, @bitCast(result[0]));
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
    //std.debug.print("Running tests in src/root.zig \"main\"\n", .{});

    //try main();
}

//const exe_main = @import("main.zig").main;
test "test exe main() within lib" {
    //try exe_main();
}

test "signed/unsigned int cast" {
    const signed: i8 = -1;
    const unsigned: u8 = @as(u8, @bitCast(signed)); // Cast -1 i8 to 255 u8
    //std.debug.print("unsigned: {}\n", .{unsigned}); // Prints: 255
    try std.testing.expectEqual(unsigned, 255);
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

test "std u8 forward start equals stop ex empty range in one iteration range" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 1, false, 1);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 1, true, 1);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 1);
}

test "std u8 backward start equals stop ex empty range in one iteration range" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 1, false, -1);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 1, true, -1);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 1);
}

test "std u8 forward start equals stop ex empty range in one iteration range step over 1" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 1, false, 2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 1, true, 2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 1);
}

test "std u8 backward start equals stop ex empty range in one iteration range step over 1" {
    // Integer range (forward)
    var s_e: u16 = 0;
    var range_e = try WhileRange(u8).init(1, 1, false, -2);
    while (range_e.next()) |value| {
        s_e += value;
    }
    try std.testing.expectEqual(s_e, 0);

    var s_i: u16 = 0;
    var range_i = try WhileRange(u8).init(1, 1, true, -2);
    while (range_i.next()) |value| {
        s_i += value;
    }
    try std.testing.expectEqual(s_i, 1);
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
