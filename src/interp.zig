//! Helpers for working with various interpolation schemes.

const std = @import("std");
const geom = @import("root.zig");

const assert = std.debug.assert;

/// Linear interpolation, exact results at `0` and `1`.
///
/// Supports floats, vectors of floats, and structs or arrays that only contain other supported
/// types.
pub fn lerp(
    start: anytype,
    end: anytype,
    t: anytype,
) switch (@typeInfo(@TypeOf(start, end))) {
    .float, .comptime_float => @TypeOf(start, end, t),
    else => @TypeOf(start, end),
} {
    // See https://github.com/ziglang/zig/issues/23075
    const Type = switch (@typeInfo(@TypeOf(start, end))) {
        .float, .comptime_float => @TypeOf(start, end, t),
        else => @TypeOf(start, end),
    };
    switch (@typeInfo(Type)) {
        .float, .comptime_float => return @mulAdd(Type, start, 1.0 - t, end * t),
        .vector => return @mulAdd(
            Type,
            start,
            @splat(1.0 - t),
            @as(Type, end) * @as(Type, @splat(@floatCast(t))),
        ),
        .@"struct" => |info| {
            var result: Type = undefined;
            inline for (info.fields) |field| {
                @field(result, field.name) = lerp(
                    @field(start, field.name),
                    @field(end, field.name),
                    t,
                );
            }
            return result;
        },
        .array => {
            var result: Type = undefined;
            for (&result, start, end) |*dest, a, b| {
                dest.* = lerp(a, b, t);
            }
            return result;
        },
        else => comptime unreachable,
    }
}

test lerp {
    const expectEqual = std.testing.expectEqual;
    const ct = comptime_float;

    // Float values
    {
        try expectEqual(100.0, lerp(100.0, 200.0, 0.0));
        try expectEqual(200.0, lerp(100.0, 200.0, 1.0));
        try expectEqual(150.0, lerp(100.0, 200.0, @as(f32, 0.5)));
    }

    // Float types
    {
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(f32, 0)));

        try expectEqual(@as(f64, 0), lerp(@as(f64, 0), @as(f32, 0), @as(f32, 0)));
        try expectEqual(@as(f64, 0), lerp(@as(f32, 0), @as(f64, 0), @as(f32, 0)));
        try expectEqual(@as(f64, 0), lerp(@as(f32, 0), @as(f32, 0), @as(f64, 0)));

        try expectEqual(@as(f64, 0), lerp(@as(f64, 0), @as(f64, 0), @as(f32, 0)));
        try expectEqual(@as(f64, 0), lerp(@as(f64, 0), @as(f32, 0), @as(f64, 0)));
        try expectEqual(@as(f64, 0), lerp(@as(f32, 0), @as(f64, 0), @as(f64, 0)));

        try expectEqual(@as(f64, 0), lerp(@as(f64, 0), @as(f64, 0), @as(f64, 0)));
    }

    // Comptime float types
    {
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(f32, 0)));

        try expectEqual(@as(f32, 0), lerp(@as(ct, 0), @as(f32, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(ct, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(ct, 0)));

        try expectEqual(@as(f32, 0), lerp(@as(ct, 0), @as(ct, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(ct, 0), @as(f32, 0), @as(ct, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(ct, 0), @as(ct, 0)));

        try expectEqual(@as(ct, 0), lerp(@as(ct, 0), @as(ct, 0), @as(ct, 0)));
    }

    // Vectors
    {
        const a: @Vector(3, f32) = .{ 0.0, 50.0, 100.0 };
        const b: @Vector(3, f32) = .{ 100.0, 0.0, 200.0 };
        try expectEqual(@Vector(3, f32){ 0.0, 50.0, 100.0 }, lerp(a, b, @as(ct, 0.0)));
        try expectEqual(@Vector(3, f32){ 50.0, 25.0, 150.0 }, lerp(a, b, @as(f32, 0.5)));
        try expectEqual(@Vector(3, f32){ 100.0, 0.0, 200.0 }, lerp(a, b, @as(f32, 1)));
    }

    // Vector types
    {
        try expectEqual(@Vector(3, f32), @TypeOf(lerp(
            @Vector(3, f32){ 0.0, 0.0, 0.0 },
            @Vector(3, f32){ 0.0, 0.0, 0.0 },
            @as(f32, 0.0),
        )));
        try expectEqual(@Vector(3, f32), @TypeOf(lerp(
            .{ 0.0, 0.0, 0.0 },
            @Vector(3, f32){ 0.0, 0.0, 0.0 },
            @as(f32, 0.0),
        )));
        try expectEqual(@Vector(3, f32), @TypeOf(lerp(
            @Vector(3, f32){ 0.0, 0.0, 0.0 },
            .{ 0.0, 0.0, 0.0 },
            @as(f32, 0.0),
        )));
    }

    // Structs
    {
        const Vec3 = struct { x: f32, y: f32, z: f32 };
        const a: Vec3 = .{ .x = 0.0, .y = 50.0, .z = 100.0 };
        const b: Vec3 = .{ .x = 100.0, .y = 0.0, .z = 200.0 };
        try std.testing.expectEqual(Vec3{ .x = 0.0, .y = 50.0, .z = 100.0 }, lerp(a, b, 0.0));
        try std.testing.expectEqual(Vec3{ .x = 50.0, .y = 25.0, .z = 150.0 }, lerp(a, b, 0.5));
        try std.testing.expectEqual(Vec3{ .x = 100.0, .y = 0.0, .z = 200.0 }, lerp(a, b, 1.0));
    }

    // Tuples
    {
        const a = .{ 0.0, 50.0, 100.0 };
        const b = .{ 100.0, 0.0, 200.0 };
        try std.testing.expectEqual(.{ 0.0, 50.0, 100.0 }, lerp(a, b, 0.0));
        try std.testing.expectEqual(.{ 50.0, 25.0, 150.0 }, lerp(a, b, 0.5));
        try std.testing.expectEqual(.{ 100.0, 0.0, 200.0 }, lerp(a, b, 1.0));
    }

    // Array
    {
        const a: [3]f32 = .{ 0, 50, 100 };
        const b: [3]f32 = .{ 100, 0, 200 };
        try expectEqual([3]f32{ 0, 50, 100 }, lerp(a, b, @as(ct, 0)));
        try expectEqual([3]f32{ 50, 25, 150 }, lerp(a, b, @as(f32, 0.5)));
        try expectEqual([3]f32{ 100, 0, 200 }, lerp(a, b, @as(f32, 1)));
    }
}

/// Inverse linear interpolation, gives exact results at 0 and 1.
///
/// Only supports floats.
pub fn ilerp(start: anytype, end: anytype, val: anytype) @TypeOf(start, end, val) {
    const Type = @TypeOf(start, end, val);
    comptime assert(@typeInfo(Type) == .float or @typeInfo(Type) == .comptime_float);
    return (val - start) / (end - start);
}

test ilerp {
    try std.testing.expectEqual(0.0, ilerp(50.0, 100.0, 50.0));
    try std.testing.expectEqual(1.0, ilerp(50.0, 100.0, 100.0));
    try std.testing.expectEqual(0.5, ilerp(50.0, 100.0, 75.0));
}

/// Clamps a value between 0 and 1.
pub fn clamp01(val: anytype) @TypeOf(val) {
    return @max(0.0, @min(1.0, val));
}

test clamp01 {
    try std.testing.expectEqual(0.0, clamp01(-1.0));
    try std.testing.expectEqual(1.0, clamp01(10.0));
    try std.testing.expectEqual(0.5, clamp01(0.5));
}

/// Remaps a value from the start range into the end range.
///
/// Only supports floats.
pub fn remap(
    in_start: anytype,
    in_end: anytype,
    out_start: anytype,
    out_end: anytype,
    val: anytype,
) @TypeOf(in_start, in_end, out_start, out_end, val) {
    const t = ilerp(in_start, in_end, val);
    return lerp(out_start, out_end, t);
}

test remap {
    try std.testing.expectEqual(50.0, remap(10.0, 20.0, 50.0, 100.0, 10.0));
    try std.testing.expectEqual(100.0, remap(10.0, 20.0, 50.0, 100.0, 20.0));
    try std.testing.expectEqual(75.0, remap(10.0, 20.0, 50.0, 100.0, 15.0));
}

/// Processes a delta time value to make it usable as the `t` argument to lerp.
///
/// It's often tempting to pass delta time into lerp to create smooth motion, e.g. to smoothly move
/// a follow camera towards a position behind the player each frame, but this is not framerate
/// independent.
///
/// This function processes a delta time value, returning a `t` value that can be used for framerate
/// independent lerp.
///
/// The smoothing parameter ranges from zero to one, higher values result in more smoothing. In
/// particular, the smoothing value is appropriately equivalent to the distance from t = 1 the
/// return value will be for a delta time of one.
///
/// A nice write up elaborating on this concept can be found here:
/// https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
pub fn damp(smoothing: anytype, dt: anytype) @TypeOf(dt) {
    return 1.0 - std.math.pow(@TypeOf(dt), @floatCast(smoothing), dt);
}

test damp {
    try std.testing.expectEqual(1.0, damp(0.0, @as(f32, 1.0)));
    try std.testing.expectEqual(0.8, damp(0.2, @as(f32, 1.0)));
    try std.testing.expectEqual(0.5, damp(0.5, @as(f32, 1.0)));
}
