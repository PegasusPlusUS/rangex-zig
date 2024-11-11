const std = @import("std");

fn Range(comptime T: type) type {
    // Verify T is a numeric type
    comptime {
        switch (@typeInfo(T)) {
            .Int, .Float => {},
            else => @compileError("Range only supports numeric types"),
        }
    }

    return struct {
        start: T,
        end: T,
        step: T,
        curr: T,

        const Self = @This();

        pub fn init(start: T, end: T, step: T) !Self {
            // Validate step isn't zero
            if (step == 0) return error.ZeroStep;

            return Self{
                .start = start,
                .end = end,
                .step = step,
                .curr = start,
            };
        }

        pub fn next(self: *Self) ?T {
            // Handle both forward and backward iteration
            const valid = if (self.step > 0)
                self.curr < self.end
            else
                self.curr > self.end;

            if (!valid) return null;

            const value = self.curr;
            self.curr += self.step;
            return value;
        }
    };
}

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
