const std = @import("std");
const IndexedWhileRange = @import("while_rangex").IndexedWhileRange;

test "std u8 exclusive edge, can't directly iterator through full u8" {
    // std for in zig only allow usize
    // Loop from -128 to 127 exclusive
    //for (std.math.minInt(i8)..std.math.maxInt(i8)) |i| {
    // Do something with `i`
    //    std.debug.print("i: {}\n", .{i});
    //}
    const start: u8 = 0;
    const end: u8 = 255;
    var index: usize = 0;
    for (start..end) |n| {
        try std.testing.expect(start <= n);
        try std.testing.expect(n < end);
        index += 1;
    }
    try std.testing.expect(index == end - start);

    const mini8 = std.math.minInt(i8);
    const maxi8 = std.math.maxInt(i8);
    for (0..maxi8 - mini8 + 1) |n| {
        // Extend 1 more bit to avoid value out of i8 range
        const ni9 = @as(i9, @intCast(n)) + @as(i9, mini8);
        try std.testing.expect(ni9 >= @as(i9, mini8));
        try std.testing.expect(ni9 <= @as(i9, maxi8));
        // Now get fully iterated n within i8
        const ni8 = @as(i8, @intCast(ni9));
        if (ni8 != ni8) {
            break;
        }
    }
}

fn get_range_end_mark_u8(inclusive: bool) u8 {
    if (inclusive) {
        return ']';
    } else {
        return ')';
    }
}

fn get_range_begin_mark_u8(inclusive: bool) u8 {
    if (inclusive) {
        return '[';
    } else {
        return '(';
    }
}

pub fn get_extended_signed_int_type(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Int => |info| {
            if (info.bits <= 8) return i16;
            if (info.bits <= 16) return i32;
            if (info.bits <= 32) return i64;
            if (info.bits <= 64) return i128;
            if (info.bits <= 128) return i256;
            if (info.bits <= 256) return i512;
            if (info.bits <= 512) return i1024;
            return T; // Default case, return the same type if it's already large enough
        },
        else => @compileError("Unsupported type"),
    }
}

pub fn extendedSignedT(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Int => |int_info| std.meta.Int(.signed, 2 * int_info.bits),
        else => T,
    };
}

test "get_extend_int for various integer types" {
    const extended_u8 = get_extended_signed_int_type(u8);
    const extended_i8 = get_extended_signed_int_type(i8);
    const extended_u16 = get_extended_signed_int_type(u16);
    const extended_i16 = get_extended_signed_int_type(i16);
    const extended_u32 = get_extended_signed_int_type(u32);
    const extended_i32 = get_extended_signed_int_type(i32);
    const extended_u64 = get_extended_signed_int_type(u64);
    const extended_i64 = get_extended_signed_int_type(i64);
    const extended_u128 = get_extended_signed_int_type(u128);
    const extended_i128 = get_extended_signed_int_type(i128);
    const extended_u256 = get_extended_signed_int_type(u256);
    const extended_i256 = get_extended_signed_int_type(i256);
    const extended_u512 = get_extended_signed_int_type(u512);
    const extended_i512 = get_extended_signed_int_type(i512);

    std.debug.print("extended_u8: {s}\n", .{@typeName(extended_u8)});
    std.debug.print("extended_i8: {s}\n", .{@typeName(extended_i8)});
    std.debug.print("extended_u16: {s}\n", .{@typeName(extended_u16)});
    std.debug.print("extended_i16: {s}\n", .{@typeName(extended_i16)});
    std.debug.print("extended_u32: {s}\n", .{@typeName(extended_u32)});
    std.debug.print("extended_i32: {s}\n", .{@typeName(extended_i32)});
    std.debug.print("extended_u64: {s}\n", .{@typeName(extended_u64)});
    std.debug.print("extended_i64: {s}\n", .{@typeName(extended_i64)});
    std.debug.print("extended_u128: {s}\n", .{@typeName(extended_u128)});
    std.debug.print("extended_i128: {s}\n", .{@typeName(extended_i128)});
    std.debug.print("extended_u256: {s}\n", .{@typeName(extended_u256)});
    std.debug.print("extended_i256: {s}\n", .{@typeName(extended_i256)});
    std.debug.print("extended_u512: {s}\n", .{@typeName(extended_u512)});
    std.debug.print("extended_i512: {s}\n", .{@typeName(extended_i512)});
    std.debug.print("max value of {s} is {}\n", .{ @typeName(extended_u512), std.math.maxInt(extended_u512) });
    //std.debug.print("max value of {s} is {}\n", .{ @typeName(u4096), std.math.maxInt(u4096) });
    //std.debug.print("max value of {s} is {}\n", .{ @typeName(u8192), std.math.maxInt(u8192) });

    //Arbitray uint, but will cause long compile time to generate
    //max value of u8192 is 1090748135619415929462984244733782862448264161996232692431832786189721331849119295216264234525201987223957291796157025273109870820177184063610979765077554799078906298842192989538609825228048205159696851613591638196771886542609324560121290553901886301017900252535799917200010079600026535836800905297805880952350501630195475653911005312364560014847426035293551245843928918752768696279344088055617515694349945406677825140814900616105920256438504578013326493565836047242407382442812245131517757519164899226365743722432277368075027627883045206501792761700945699168497257879683851737049996900961120515655050115561271491492515342105748966629547032786321505730828430221664970324396138635251626409516168005427623435996308921691446181187406395310665404885739434832877428167407495370993511868756359970390117021823616749458620969857006263612082706715408157066575137281027022310927564910276759160520878304632411049364568754920967322982459184763427383790272448438018526977764941072715611580434690827459339991961414242741410599117426060556483763756314527611362658628383368621157993638020878537675545336789915694234433955666315070087213535470255670312004130725495834508357439653828936077080978550578912967907352780054935621561090795845172954115972927479877527738560008204118558930004777748727761853813510493840581861598652211605960308356405941821189714037868726219481498727603653616298856174822413033485438785324024751419417183012281078209729303537372804574372095228703622776363945290869806258422355148507571039619387449629866808188769662815778153079393179093143648340761738581819563002994422790754955061288818308430079648693232179158765918035565216157115402992120276155607873107937477466841528362987708699450152031231862594203085693838944657061346236704234026821102958954951197087076546186622796294536451620756509351018906023773821539532776208676978589731966330308893304665169436185078350641568336944530051437491311298834367265238595404904273455928723949525227184617404367854754610474377019768025576605881038077270707717942221977090385438585844095492116099852538903974655703943973086090930596963360767529964938414598185705963754561497355827813623833288906309004288017321424808663962671333528009232758350873059614118723781422101460198615747386855096896089189180441339558524822867541113212638793675567650340362970031930023397828465318547238244232028015189689660418822976000815437610652254270163595650875433851147123214227266605403581781469090806576468950587661997186505665475715792895

    try std.testing.expect(@typeName(extended_u8) == @typeName(i16));
    try std.testing.expectEqual(@typeName(extended_i8), @typeName(i16));
    try std.testing.expectEqual(@typeName(extended_u16), @typeName(i32));
    try std.testing.expectEqual(@typeName(extended_i16), "i32");
    try std.testing.expectEqual(@typeName(extended_u32), "i64");
    try std.testing.expectEqual(@typeName(extended_i32), "i64");
    try std.testing.expectEqual(@typeName(extended_u64), "i128");
    try std.testing.expectEqual(@typeName(extended_i64), "i128");
}

pub fn signedT(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Int => |int_info| if (int_info.signedness == .unsigned)
            std.meta.Int(.signed, int_info.bits)
        else
            T,
        else => T,
    };
}

fn intEdge(comptime T: type, inclusive: bool) !void {
    try intEdgeWithStep(T, inclusive, 1);
}

fn intEdgeWithStep(comptime T: type, inclusive: bool, step: signedT(T)) !void {
    const intMin: T = std.math.minInt(T);
    const intMax: T = std.math.maxInt(T);
    const range_size: extendedSignedT(T) = @as(extendedSignedT(T), @intCast(intMax)) - @as(extendedSignedT(T), @intCast(intMin));
    const steps: extendedSignedT(T) = @divFloor(range_size, step);
    const on_step = @rem(range_size, step) == 0;
    const debug_print = false;
    {
        std.debug.print("{s} while range [{}, {}{c}, step {}", .{ @typeName(T), intMin, intMax, get_range_end_mark_u8(inclusive), step });
        if (debug_print) {
            std.debug.print(" range_size {}, steps {}/{}, on_step {}:\n", .{ range_size, steps, @as(usize, @intCast(steps)), on_step });
        }
        std.debug.print("\n", .{});
        var range = try IndexedWhileRange(T).init(intMin, intMax, inclusive, step);
        var index: usize = 0;
        while (range.next()) |element| {
            try std.testing.expectEqual(element.index, index);
            index += 1;
            if (inclusive or !on_step) {
                try std.testing.expect(element.index <= @as(usize, @intCast(steps)));
            } else {
                try std.testing.expect(element.index < @as(usize, @intCast(steps)));
            }
        }

        if (inclusive or !on_step) {
            try std.testing.expectEqual(@as(usize, @intCast(steps + 1)), index);
        } else {
            try std.testing.expectEqual(@as(usize, @intCast(steps)), index);
        }
    }

    // Backward
    {
        std.debug.print("Backward {s} while range {c}{}, {}], step: -{}:\n", .{ @typeName(T), get_range_begin_mark_u8(inclusive), intMin, intMax, step });
        var range = try IndexedWhileRange(T).init(intMax, intMin, inclusive, 0 - step);
        var index: usize = 0;
        while (range.next()) |element| {
            try std.testing.expectEqual(element.index, index);
            index += 1;
            if (inclusive or !on_step) {
                try std.testing.expect(element.index <= @as(usize, @intCast(steps)));
            } else {
                try std.testing.expect(element.index < @as(usize, @intCast(steps)));
            }
        }

        if (inclusive or !on_step) {
            try std.testing.expectEqual(@as(usize, @intCast(steps + 1)), index);
        } else {
            try std.testing.expectEqual(@as(usize, @intCast(steps)), index);
        }
    }
}

test "i8 exclusive edge" {
    try intEdge(i8, false);
}

test "i8 exclusive edge not on step" {
    try intEdgeWithStep(i8, false, 3);
}

test "i8 exclusive edge on step" {
    try intEdgeWithStep(i8, false, 5);
}

test "i8 exclusive edge min step" {
    //try intEdgeWithStep(i8, false, std.math.minInt(i8));
    std.testing.expect(false) catch |e| {
        std.debug.print("To do {}\n", .{e});
    };
}

test "i8 exclusive edge max step" {
    try intEdgeWithStep(i8, false, std.math.maxInt(i8));
}

test "i8 inclusive edge" {
    try intEdge(i8, true);
}

test "i8 inclusive edge not on step" {
    try intEdgeWithStep(i8, true, 3);
}

test "i8 inclusive edge on step" {
    try intEdgeWithStep(i8, true, 5);
}

test "u8 exclusive edge" {
    try intEdge(u8, false);
}

test "u8 exclusive edge not on step" {
    try intEdgeWithStep(u8, false, 3);
}

test "u8 exclusive edge on step" {
    try intEdgeWithStep(u8, false, 5);
}

test "u8 inclusive edge" {
    try intEdge(u8, true);
}

test "u8 inclusive edge not on step" {
    try intEdgeWithStep(u8, true, 3);
}

test "u8 inclusive edge on step" {
    try intEdgeWithStep(u8, true, 5);
}

test "i16 exclusive edge" {
    try intEdge(i16, false);
}

test "i16 exclusive edge not on step" {
    try intEdgeWithStep(i16, false, 3);
}

test "i16 exclusive edge on step" {
    try intEdgeWithStep(i16, false, 5);
}

test "i16 inclusive edge" {
    try intEdge(i16, true);
}

test "i16 inclusive edge not on step" {
    try intEdgeWithStep(i16, true, 3);
}

test "i16 inclusive edge on step" {
    try intEdgeWithStep(i16, true, 5);
}

test "u16 exclusive edge" {
    try intEdge(u16, false);
}

test "u16 exclusive edge not on step" {
    try intEdgeWithStep(u16, false, 3);
}

test "u16 exclusive edge on step" {
    try intEdgeWithStep(u16, false, 5);
}

test "u16 inclusive edge" {
    try intEdge(u16, true);
}

test "u16 inclusive edge not on step" {
    try intEdgeWithStep(u16, true, 3);
}

test "u16 inclusive edge on step" {
    try intEdgeWithStep(u16, true, 5);
}

test "i24 exclusive edge" {
    try intEdgeWithStep(i24, false, std.math.maxInt(i8));
    try intEdgeWithStep(i24, false, std.math.maxInt(i8) + 1);
}

test "i24 inclusive edge" {
    try intEdgeWithStep(i24, true, std.math.maxInt(i8));
    try intEdgeWithStep(i24, true, std.math.maxInt(i8) + 1);
}

test "u24 exclusive edge" {
    try intEdgeWithStep(u24, false, std.math.maxInt(i8));
    try intEdgeWithStep(u24, false, std.math.maxInt(i8) + 1);
}

test "u24 inclusive edge" {
    try intEdgeWithStep(u24, true, std.math.maxInt(i8));
    try intEdgeWithStep(u24, true, std.math.maxInt(i8) + 1);
}

test "i32 exclusive edge" {
    try intEdgeWithStep(i32, false, std.math.maxInt(i16));
    try intEdgeWithStep(i32, false, std.math.maxInt(i16) + 1);
}

test "i32 inclusive edge" {
    try intEdgeWithStep(i32, true, std.math.maxInt(i16));
    try intEdgeWithStep(i32, true, std.math.maxInt(i16) + 1);
}

test "u32 exclusive edge" {
    try intEdgeWithStep(u32, false, std.math.maxInt(i16));
    try intEdgeWithStep(u32, false, std.math.maxInt(i16) + 1);
}

test "u32 inclusive edge" {
    try intEdgeWithStep(u32, true, std.math.maxInt(i16));
    try intEdgeWithStep(u32, true, std.math.maxInt(i16) + 1);
}

test "i64 exclusive edge" {
    try intEdgeWithStep(i64, false, std.math.maxInt(i48));
    try intEdgeWithStep(i64, false, std.math.maxInt(i48) + 1);
}

test "i64 inclusive edge" {
    try intEdgeWithStep(i64, true, std.math.maxInt(i48));
    try intEdgeWithStep(i64, true, std.math.maxInt(i48) + 1);
}

test "u64 exclusive edge" {
    try intEdgeWithStep(u64, false, std.math.maxInt(i48));
    try intEdgeWithStep(u64, false, std.math.maxInt(i48) + 1);
}

test "u64 inclusive edge" {
    try intEdgeWithStep(u64, true, std.math.maxInt(i48));
    try intEdgeWithStep(u64, true, std.math.maxInt(i48) + 1);
}

test "i128 exclusive edge" {
    try intEdgeWithStep(i128, false, std.math.maxInt(i112));
    try intEdgeWithStep(i128, false, std.math.maxInt(i112) + 1);
}

test "i128 inclusive edge" {
    try intEdgeWithStep(i128, true, std.math.maxInt(i112));
    try intEdgeWithStep(i128, true, std.math.maxInt(i112) + 1);
}

test "u128 exclusive edge" {
    try intEdgeWithStep(u128, false, std.math.maxInt(i112));
    try intEdgeWithStep(u128, false, std.math.maxInt(i112) + 1);
}

test "u128 inclusive edge" {
    try intEdgeWithStep(u128, true, std.math.maxInt(i112));
    try intEdgeWithStep(u128, true, std.math.maxInt(i112) + 1);
}

test "float exclusive edge" {
    //try intEdgeWithStep(f32, true, std.math.maxInt(i24));
    //try intEdgeWithStep(f32, true, std.math.maxInt(i24) + 1);
    std.testing.expect(false) catch |e| {
        std.debug.print("To do {}\n", .{e});
        return error.TestUnexpectedResult;
    };
}

test "float to do, min/max" {
    std.testing.expect(false) catch |e| {
        std.debug.print("To do {}\n", .{e});
        return e;
    };
}

test "example test" {
    const result = std.testing.expect(1 == 1) catch |err| {
        std.debug.print("Test failed with error: {}\n", .{err});
        return;
    };
    std.debug.print("Example test passed with result: {}\n", .{result});
}
