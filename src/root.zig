const std = @import("std");

const IntRange = struct {
    start: i32,
    end: i32,
    curr: i32,

    pub fn init(start: i32, end: i32) IntRange {
        return IntRange{
            .start = start,
            .end = end,
            .curr = start,
        };
    }

    pub fn next(self: *IntRange) ?i32 {
        if (self.curr >= self.end) {
            return null;
        }
        const result = self.curr;
        self.curr += 1;
        return result;
    }

    pub fn iterator(self: *IntRange) *IntRange {
        return self;
    }
};

pub fn main() void {
    var int_range = IntRange.init(0, 10);
    std.debug.print("Integer range:\n", .{});
    // Use the custom iterator in a for loop
    var iter = int_range.iterator();
    while (iter.next()) |value| {
        std.debug.print("{}\n", .{value});
    }
}
