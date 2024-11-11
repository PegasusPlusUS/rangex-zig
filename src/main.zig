const std = @import("std");

const Range = struct {
    start: i32,
    end: i32,
    curr: i32,

    pub fn init(start: i32, end: i32) Range {
        return Range{
            .start = start,
            .end = end,
            .curr = start,
        };
    }

    pub fn next(self: *Range) ?i32 {
        if (self.curr >= self.end) return null;
        const value = self.curr;
        self.curr += 1;
        return value;
    }
};

pub fn main() void {
    var range = Range.init(0, 10);

    while (range.next()) |value| {
        std.debug.print("{}\n", .{value});
    }
}
