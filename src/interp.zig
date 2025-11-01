//! Helpers for working with various interpolation schemes.

const std = @import("std");
const geom = @import("root.zig");

const assert = std.debug.assert;

/// Coerce to a float type if possible.
fn PreferFloats(T: type) type {
    switch (@typeInfo(T)) {
        .float, .comptime_float => return T,
        .comptime_int => return comptime_float,
        else => return T,
    }
}

/// The type returned by `lerp`.
fn Lerp(Start: type, End: type, T: type) type {
    const start: PreferFloats(Start) = undefined;
    const end: PreferFloats(End) = undefined;
    const t: PreferFloats(T) = undefined;
    switch (@typeInfo(@TypeOf(start, end))) {
        .float, .comptime_float => return @TypeOf(start, end, t),
        else => return @TypeOf(start, end),
    }
}

/// Linear interpolation, exact results at `0` and `1`.
///
/// Supports floats, vectors of floats, and structs or arrays that only contain other supported
/// types. Comptime ints are coerced to comptime floats.
pub fn lerp(
    start: anytype,
    end: anytype,
    t: anytype,
) Lerp(@TypeOf(start), @TypeOf(end), @TypeOf(t)) {
    const Type = Lerp(@TypeOf(start), @TypeOf(end), @TypeOf(t));
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
    const ctf = comptime_float;
    const cti = comptime_int;

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

        try expectEqual(@as(f32, 0), lerp(@as(ctf, 0), @as(f32, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(ctf, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(ctf, 0)));

        try expectEqual(@as(f32, 0), lerp(@as(ctf, 0), @as(ctf, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(ctf, 0), @as(f32, 0), @as(ctf, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(ctf, 0), @as(ctf, 0)));

        try expectEqual(@as(ctf, 0), lerp(@as(ctf, 0), @as(ctf, 0), @as(ctf, 0)));
    }

    // Comptime int types
    {
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(f32, 0)));

        try expectEqual(@as(f32, 0), lerp(@as(cti, 0), @as(f32, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(cti, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(f32, 0), @as(cti, 0)));

        try expectEqual(@as(f32, 0), lerp(@as(cti, 0), @as(cti, 0), @as(f32, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(cti, 0), @as(f32, 0), @as(cti, 0)));
        try expectEqual(@as(f32, 0), lerp(@as(f32, 0), @as(cti, 0), @as(cti, 0)));

        try expectEqual(@as(cti, 0), lerp(@as(cti, 0), @as(cti, 0), @as(cti, 0)));
    }

    // Vectors, and checking for lack of clamping
    {
        const a: @Vector(3, f32) = .{ 0.0, 50.0, 100.0 };
        const b: @Vector(3, f32) = .{ 100.0, 0.0, 200.0 };
        try expectEqual(@Vector(3, f32){ -100.0, 100.0, 0.0 }, lerp(a, b, @as(ctf, -1.0)));
        try expectEqual(@Vector(3, f32){ 0.0, 50.0, 100.0 }, lerp(a, b, @as(ctf, 0.0)));
        try expectEqual(@Vector(3, f32){ 50.0, 25.0, 150.0 }, lerp(a, b, @as(f32, 0.5)));
        try expectEqual(@Vector(3, f32){ 100.0, 0.0, 200.0 }, lerp(a, b, @as(f32, 1)));
        try expectEqual(@Vector(3, f32){ 200.0, -50.0, 300.0 }, lerp(a, b, @as(ctf, 2.0)));
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
        try expectEqual([3]f32{ 0, 50, 100 }, lerp(a, b, @as(ctf, 0)));
        try expectEqual([3]f32{ 50, 25, 150 }, lerp(a, b, @as(f32, 0.5)));
        try expectEqual([3]f32{ 100, 0, 200 }, lerp(a, b, @as(f32, 1)));
    }
}

/// Similar to `lerp`, but `t` is clamped to [0, 1].
pub fn lerpClamped(
    start: anytype,
    end: anytype,
    t: anytype,
) @TypeOf(lerp(start, end, t)) {
    return lerp(start, end, clamp01(t));
}

test lerpClamped {
    const expectEqual = std.testing.expectEqual;
    const ctf = comptime_float;
    const a: @Vector(3, f32) = .{ 0.0, 50.0, 100.0 };
    const b: @Vector(3, f32) = .{ 100.0, 0.0, 200.0 };
    try expectEqual(@Vector(3, f32){ 0.0, 50.0, 100.0 }, lerpClamped(a, b, @as(ctf, -1.0)));
    try expectEqual(@Vector(3, f32){ 0.0, 50.0, 100.0 }, lerpClamped(a, b, @as(ctf, 0.0)));
    try expectEqual(@Vector(3, f32){ 50.0, 25.0, 150.0 }, lerpClamped(a, b, @as(f32, 0.5)));
    try expectEqual(@Vector(3, f32){ 100.0, 0.0, 200.0 }, lerpClamped(a, b, @as(f32, 1)));
    try expectEqual(@Vector(3, f32){ 100.0, 0.0, 200.0 }, lerpClamped(a, b, @as(f32, 2)));
}

/// The type returned by `ilerp`.
fn Ilerp(Start: type, End: type, Val: type) type {
    const start: PreferFloats(Start) = undefined;
    const end: PreferFloats(End) = undefined;
    const val: PreferFloats(Val) = undefined;
    return @TypeOf(start, end, val);
}

/// Inverse linear interpolation, gives exact results at 0 and 1.
///
/// Supports the same types as `lerp`, types with multiple components are computed componentwise.
pub fn ilerp(
    start: anytype,
    end: anytype,
    val: anytype,
) Ilerp(@TypeOf(start), @TypeOf(end), @TypeOf(val)) {
    const Type = Ilerp(@TypeOf(start), @TypeOf(end), @TypeOf(val));
    // comptime assert(@typeInfo(Type) == .float or @typeInfo(Type) == .comptime_float);
    switch (@typeInfo(Type)) {
        .float, .comptime_float, .vector => {
            return (@as(Type, val) - @as(Type, start)) / (@as(Type, end) - @as(Type, start));
        },
        .@"struct" => |info| {
            var result: Type = undefined;
            inline for (info.fields) |field| {
                @field(result, field.name) = ilerp(
                    @field(start, field.name),
                    @field(end, field.name),
                    @field(val, field.name),
                );
            }
            return result;
        },
        .array => {
            var result: Type = undefined;
            for (&result, start, end, val) |*dest, a, b, t| {
                dest.* = ilerp(a, b, t);
            }
            return result;
        },
        else => comptime unreachable,
    }
}

test ilerp {
    // Floats
    try std.testing.expectEqual(-1.0, ilerp(50.0, 100.0, 0.0));
    try std.testing.expectEqual(@as(f32, 0.0), ilerp(50.0, 100.0, 50.0));
    try std.testing.expectEqual(0.5, ilerp(@as(f32, 50.0), 100.0, 75.0));
    try std.testing.expectEqual(1.0, ilerp(50.0, @as(f32, 100.0), 100.0));
    try std.testing.expectEqual(2.0, ilerp(50.0, 100.0, @as(f32, 150.0)));

    // Make sure comptime ints can coerce to comptime floats
    try std.testing.expectEqual(-1.0, ilerp(50, 100.0, 0.0));
    try std.testing.expectEqual(-1.0, ilerp(50.0, 100, 0.0));
    try std.testing.expectEqual(-1.0, ilerp(50.0, 100.0, 0));
    try std.testing.expectEqual(-1.0, ilerp(50, 100, 0.0));
    try std.testing.expectEqual(-1.0, ilerp(50, 100.0, 0));
    try std.testing.expectEqual(-1.0, ilerp(50.0, 100, 0));
    try std.testing.expectEqual(-1.0, ilerp(50, 100, 0));

    // Vectors
    {
        const Vec2 = @Vector(2, f32);
        try std.testing.expectEqual(
            Vec2{ -1.0, 0.5 },
            ilerp(Vec2{ 50, 0 }, Vec2{ 100, 100 }, Vec2{ 0, 50 }),
        );
    }

    // Structs
    {
        const Vec2 = struct { x: f32, y: f32 };
        try std.testing.expectEqual(
            Vec2{ .x = -1.0, .y = 0.5 },
            ilerp(Vec2{ .x = 50, .y = 0 }, Vec2{ .x = 100, .y = 100 }, Vec2{ .x = 0, .y = 50 }),
        );
    }

    // Tuples
    {
        const Vec2 = struct { f32, f32 };
        try std.testing.expectEqual(
            Vec2{ -1.0, 0.5 },
            ilerp(Vec2{ 50, 0 }, Vec2{ 100, 100 }, Vec2{ 0, 50 }),
        );
    }

    // Arrays
    {
        const Vec2 = [2]f32;
        try std.testing.expectEqual(
            Vec2{ -1.0, 0.5 },
            ilerp(Vec2{ 50, 0 }, Vec2{ 100, 100 }, Vec2{ 0, 50 }),
        );
    }
}

/// Similar to `ilerp`, but clamps the result to [0, 1].
pub fn ilerpClamped(start: anytype, end: anytype, val: anytype) @TypeOf(ilerp(start, end, val)) {
    return clamp01(ilerp(start, end, val));
}

test ilerpClamped {
    try std.testing.expectEqual(0.0, ilerpClamped(50.0, 100.0, 0.0));
    try std.testing.expectEqual(0.0, ilerpClamped(50.0, 100.0, 50.0));
    try std.testing.expectEqual(0.5, ilerpClamped(50.0, 100.0, 75.0));
    try std.testing.expectEqual(1.0, ilerpClamped(50.0, 100.0, 100.0));
    try std.testing.expectEqual(1.0, ilerpClamped(50.0, 100.0, 150.0));
}

fn Remap(
    InStart: type,
    InEnd: type,
    OutStart: type,
    OutEnd: type,
    Val: type,
) type {
    const T = Ilerp(InStart, InEnd, Val);
    return Lerp(OutStart, OutEnd, T);
}

/// Remaps a value from the start range into the end range.
///
/// Supports the same types as `lerp`, types with multiple components are computed componentwise.
pub fn remap(
    in_start: anytype,
    in_end: anytype,
    out_start: anytype,
    out_end: anytype,
    val: anytype,
) Remap(
    @TypeOf(in_start),
    @TypeOf(in_end),
    @TypeOf(out_start),
    @TypeOf(out_end),
    @TypeOf(val),
) {
    const Type = Remap(
        @TypeOf(in_start),
        @TypeOf(in_end),
        @TypeOf(out_start),
        @TypeOf(out_end),
        @TypeOf(val),
    );
    const t = ilerp(in_start, in_end, val);
    switch (@typeInfo(Type)) {
        .float, .comptime_float => return lerp(out_start, out_end, t),
        .vector => return @mulAdd(
            Type,
            out_start,
            @as(Type, @splat(1.0)) - t,
            @as(Type, out_end) * @as(Type, t),
        ),
        .@"struct" => |info| {
            var result: Type = undefined;
            inline for (info.fields) |field| {
                @field(result, field.name) = lerp(
                    @field(out_start, field.name),
                    @field(out_end, field.name),
                    @field(t, field.name),
                );
            }
            return result;
        },
        .array => {
            var result: Type = undefined;
            for (&result, out_start, out_end, t) |*dest, start_field, end_field, t_field| {
                dest.* = lerp(start_field, end_field, t_field);
            }
            return result;
        },
        else => comptime unreachable,
    }
}

test remap {
    try std.testing.expectEqual(0.0, remap(10.0, 20.0, 50.0, 100.0, 0.0));
    try std.testing.expectEqual(150.0, remap(10.0, 20.0, 50.0, 100.0, 30.0));

    try std.testing.expectEqual(50.0, remap(10.0, 20.0, 50.0, 100.0, 10.0));
    try std.testing.expectEqual(50.0, remap(10.0, 20.0, 50.0, 100.0, 10.0));
    try std.testing.expectEqual(100.0, remap(10.0, 20.0, 50.0, 100.0, 20.0));
    try std.testing.expectEqual(75.0, remap(10.0, 20.0, 50.0, 100.0, 15.0));

    // Check scalar types
    const f32_0: f32 = 0;
    const f64_0: f64 = 0;
    const ctf_0: comptime_float = 0;
    const cti_0: comptime_int = 0;

    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f64, @TypeOf(remap(f64_0, f32_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f64, @TypeOf(remap(f32_0, f64_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f64, @TypeOf(remap(f32_0, f32_0, f64_0, f32_0, f32_0)));
    try std.testing.expectEqual(f64, @TypeOf(remap(f32_0, f32_0, f32_0, f64_0, f32_0)));
    try std.testing.expectEqual(f64, @TypeOf(remap(f32_0, f32_0, f32_0, f32_0, f64_0)));

    try std.testing.expectEqual(f32, @TypeOf(remap(ctf_0, f32_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, ctf_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, ctf_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, f32_0, ctf_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, f32_0, f32_0, ctf_0)));

    try std.testing.expectEqual(f32, @TypeOf(remap(cti_0, f32_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, cti_0, f32_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, cti_0, f32_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, f32_0, cti_0, f32_0)));
    try std.testing.expectEqual(f32, @TypeOf(remap(f32_0, f32_0, f32_0, f32_0, cti_0)));

    // Vectors
    {
        const Vec2 = @Vector(2, f32);
        try std.testing.expectEqual(
            Vec2{ 1, 0 },
            remap(Vec2{ -1, 0 }, Vec2{ 1, 2 }, Vec2{ 0, -1 }, Vec2{ 2, 1 }, Vec2{ 0, 1 }),
        );
    }

    // Structs
    {
        const Vec2 = struct { x: f32, y: f32 };
        try std.testing.expectEqual(
            Vec2{ .x = 1, .y = 0 },
            remap(Vec2{ .x = -1, .y = 0 }, Vec2{ .x = 1, .y = 2 }, Vec2{ .x = 0, .y = -1 }, Vec2{ .x = 2, .y = 1 }, Vec2{ .x = 0, .y = 1 }),
        );
    }

    // Tuples
    {
        const Vec2 = struct { f32, f32 };
        try std.testing.expectEqual(
            Vec2{ 1, 0 },
            remap(Vec2{ -1, 0 }, Vec2{ 1, 2 }, Vec2{ 0, -1 }, Vec2{ 2, 1 }, Vec2{ 0, 1 }),
        );
    }

    // Arrays
    {
        const Vec2 = [2]f32;
        try std.testing.expectEqual(
            Vec2{ 1, 0 },
            remap(Vec2{ -1, 0 }, Vec2{ 1, 2 }, Vec2{ 0, -1 }, Vec2{ 2, 1 }, Vec2{ 0, 1 }),
        );
    }
}

/// Similar to `remap`, but the results are clamped to [start, end].
pub fn remapClamped(
    in_start: anytype,
    in_end: anytype,
    out_start: anytype,
    out_end: anytype,
    val: anytype,
) @TypeOf(in_start, in_end, out_start, out_end, val) {
    const t = ilerp(in_start, in_end, val);
    return lerpClamped(out_start, out_end, t);
}

test remapClamped {
    try std.testing.expectEqual(50.0, remapClamped(10.0, 20.0, 50.0, 100.0, 0.0));
    try std.testing.expectEqual(100.0, remapClamped(10.0, 20.0, 50.0, 100.0, 30.0));

    try std.testing.expectEqual(50.0, remapClamped(10.0, 20.0, 50.0, 100.0, 10.0));
    try std.testing.expectEqual(50.0, remapClamped(10.0, 20.0, 50.0, 100.0, 10.0));
    try std.testing.expectEqual(100.0, remapClamped(10.0, 20.0, 50.0, 100.0, 20.0));
    try std.testing.expectEqual(75.0, remapClamped(10.0, 20.0, 50.0, 100.0, 15.0));
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
/// particular, the smoothing value is approximately equivalent to the distance from t = 1 the
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
