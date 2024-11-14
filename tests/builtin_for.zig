const std = @import("std");

test "for can only use usize exclusive range" {
    var s: usize = 0;
    for (1..101) |n| {
        s += n;
    }
    std.testing.expectEqual(s, 5050) catch |e| {
        std.debug.print("Sum of [1, 100] got {}, err: {}", .{ s, e });
    };
}

// Reduce: Sum all elements, have to specify T, can't use 'anytype'
fn reduceSum(comptime T: type, arr: []const T) @TypeOf(arr[0]) {
    var sum: @TypeOf(arr[0]) = 0;
    for (arr) |item| {
        sum += item;
    }
    return sum;
}

test "over array inclusively with generated index" {
    const array = [_]i32{ 1, 2, 3, 4, 5 };
    var s: i32 = 0;
    for (0.., array, 1..array.len + 1) |index, item, verify| {
        s += item;
        try std.testing.expectEqual(array[index], item);
        try std.testing.expectEqual(item, @as(@TypeOf(array[0]), @intCast(verify)));
    }
    try std.testing.expectEqual(s, reduceSum(@TypeOf(array[0]), &array));
    try std.testing.expectEqual(s, reduceSum(@TypeOf(array[0]), array[0..]));
}

test "iterated value is const during loop" {
    var s: usize = 0;
    for (1..101) |n| {
        if (@rem(n, 2) == 1) {
            s += n;
        }
        // Can't assign n
        //n = n + 1;
    }
    std.testing.expectEqual(s, (1 + 99) * 50 / 2) catch |e| {
        std.debug.print("Sum of [1, 100] got {}, err: {}", .{ s, e });
    };
}
