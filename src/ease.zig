//! Commonly used easing styles, to be applied to the `t` value of a linear interpolation.

const std = @import("std");
const tween = @import("root.zig");

const lerp = tween.interp.lerp;
const pi = std.math.pi;

/// Linear easing does not change the time value. Provided for convenience when writing generic
/// code.
pub fn linear(t: anytype) @TypeOf(t) {
    return t;
}

test linear {
    try std.testing.expectEqual(0.0, linear(@as(f32, 0.0)));
    try std.testing.expectEqual(0.5, linear(@as(f32, 0.5)));
    try std.testing.expectEqual(0.0, linear(@as(f32, 0.0)));
}

/// Easing that follows a sine curve.
///
/// Sinusoidal easing can't guarantee exact results at 0 and 1 since it's up to your sin
/// implementation/hardware, but in practice should always be exact.
pub fn sinIn(t: anytype) @TypeOf(t) {
    return 1.0 - @cos(t * pi / 2.0);
}

test sinIn {
    try std.testing.expectEqual(@as(f32, 0.0), sinIn(@as(f32, 0.0)));
    try std.testing.expectEqual(1.0 - @cos(pi / 4.0), sinIn(@as(f32, 0.5)));
    try std.testing.expectEqual(@as(f32, 1.0), sinIn(@as(f32, 1.0)));
}

/// See `sinIn`.
pub fn sinOut(t: anytype) @TypeOf(t) {
    return @sin(t * pi / 2.0);
}

test sinOut {
    try std.testing.expectEqual(0.0, sinOut(@as(f32, 0.0)));
    try std.testing.expectEqual(@sin(pi / 4.0), sinOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, sinOut(@as(f32, 1.0)));
}

/// Eases in and out using a sine wave.
pub fn sinInOut(t: anytype) @TypeOf(t) {
    return -(@cos(pi * t) - 1.0) / 2.0;
}

test sinInOut {
    try std.testing.expectEqual(0.0, sinInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.146447), sinInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, sinInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.853553), sinInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, sinInOut(@as(f32, 1.0)));
}

/// Quadratic easing.
pub fn quadIn(t: anytype) @TypeOf(t) {
    return t * t;
}

test quadIn {
    try std.testing.expectEqual(0.0, quadIn(@as(f32, 0.0)));
    try std.testing.expectEqual(0.25, quadIn(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quadIn(@as(f32, 1.0)));
}

/// See `quadIn`.
pub fn quadOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = 1.0 - t;
    return @mulAdd(T, -inv, inv, 1.0);
}

test quadOut {
    try std.testing.expectEqual(0.0, quadOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.75, quadOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quadOut(@as(f32, 1.0)));
}

/// Quadratic ease in followed by quadratic ease out.
pub fn quadInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t < 0.5) {
        return 2 * t * t;
    } else {
        return @mulAdd(T, 4, t, -1) - 2 * t * t;
    }
}

test quadInOut {
    try std.testing.expectEqual(0.0, quadInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.125), quadInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, quadInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.875), quadInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, quadInOut(@as(f32, 1.0)));
}

/// Cubic easing.
pub fn cubicIn(t: anytype) @TypeOf(t) {
    return t * t * t;
}

test cubicIn {
    try std.testing.expectEqual(0.0, cubicIn(@as(f32, 0.0)));
    try std.testing.expectEqual(0.125, cubicIn(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, cubicIn(@as(f32, 1.0)));
}

/// See `cubicIn`.
pub fn cubicOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = 1.0 - t;
    return @mulAdd(T, inv * inv, -inv, 1.0);
}

test cubicOut {
    try std.testing.expectEqual(0.0, cubicOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.875, cubicOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, cubicOut(@as(f32, 1.0)));
}

/// Cubic ease in followed by cubic ease out.
pub fn cubicInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t < 0.5) {
        return 4 * t * t * t;
    } else {
        const c = @mulAdd(T, -2.0, t, 2.0);
        return @mulAdd(T, -c / 2.0, c * c, 1.0);
    }
}

test cubicInOut {
    try std.testing.expectEqual(0.0, cubicInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.0625), cubicInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, cubicInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.9375), cubicInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, cubicInOut(@as(f32, 1.0)));
}

/// Quartic easing.
pub fn quartIn(t: anytype) @TypeOf(t) {
    return t * t * t * t;
}

test quartIn {
    try std.testing.expectEqual(0.0, quartIn(@as(f32, 0.0)));
    try std.testing.expectEqual(0.0625, quartIn(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quartIn(@as(f32, 1.0)));
}

/// See `quartIn`.
pub fn quartOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = 1.0 - t;
    const squared = inv * inv;
    return @mulAdd(T, -squared, squared, 1.0);
}

test quartOut {
    try std.testing.expectEqual(0.0, quartOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.9375, quartOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quartOut(@as(f32, 1.0)));
}

/// Quartic ease in followed by quartic ease out.
pub fn quartInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t < 0.5) {
        return 8 * t * t * t * t;
    } else {
        const q = @mulAdd(T, -2.0, t, 2.0);
        return @mulAdd(T, -q / 2.0, q * q * q, 1.0);
    }
}

test quartInOut {
    try std.testing.expectEqual(0.0, quartInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.03125), quartInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, quartInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.96875), quartInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, quartInOut(@as(f32, 1.0)));
}

/// Quintic easing.
pub fn quintIn(t: anytype) @TypeOf(t) {
    return t * t * t * t * t;
}

test quintIn {
    try std.testing.expectEqual(0.0, quintIn(@as(f32, 0.0)));
    try std.testing.expectEqual(0.03125, quintIn(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quintIn(@as(f32, 1.0)));
}

/// See `quintIn`.
pub fn quintOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = 1.0 - t;
    const squared = inv * inv;
    return @mulAdd(T, -squared, squared * inv, 1.0);
}

test quintOut {
    try std.testing.expectEqual(0.0, quintOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.96875, quintOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, quintOut(@as(f32, 1.0)));
}

/// Quintic ease in followed by quintic ease out.
pub fn quintInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t < 0.5) {
        return 16 * t * t * t * t * t;
    } else {
        const q = @mulAdd(T, -2.0, t, 2.0);
        return @mulAdd(T, -q * q / 2.0, q * q * q, 1.0);
    }
}

test quintInOut {
    try std.testing.expectEqual(0.0, quintInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.015625), quintInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, quintInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.984375), quintInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, quintInOut(@as(f32, 1.0)));
}

/// Robert Penner's widely used exponential easing function.
pub fn expIn(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t <= 0.0) return 0;
    return std.math.pow(f32, 2, @mulAdd(T, 10, t, -10));
}

test expIn {
    try std.testing.expectEqual(0.0, expIn(@as(f32, 0.0)));
    try std.testing.expectEqual(0.03125, expIn(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, expIn(@as(f32, 1.0)));
}

/// See `expIn`.
pub fn expOut(t: anytype) @TypeOf(t) {
    return reverse(expIn, t, .{});
}

test expOut {
    try std.testing.expectEqual(0.0, expOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.96875, expOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, expOut(@as(f32, 1.0)));
}

/// Exponential ease in followed by exponential ease out.
pub fn expInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;
    if (t < 0.5) {
        return std.math.pow(f32, 2, @mulAdd(T, 20, t, -10)) / 2.0;
    } else {
        return 1.0 - std.math.pow(T, 2.0, @mulAdd(T, -20.0, t, 10.0)) / 2.0;
    }
}

test expInOut {
    try std.testing.expectEqual(0.0, expInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.015625), expInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, expInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.984375), expInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, expInOut(@as(f32, 1.0)));
}

/// Circular easing.
pub fn circIn(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    return 1.0 - @sqrt(@mulAdd(T, -t, t, 1.0));
}

test circIn {
    try std.testing.expectEqual(0.0, circIn(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.13397459621556), circIn(@as(f32, 0.5)), 0.001);
    try std.testing.expectEqual(1.0, circIn(@as(f32, 1.0)));
}

/// See `circIn`.
pub fn circOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = t - 1.0;
    return @sqrt(@mulAdd(T, -inv, inv, 1.0));
}

test circOut {
    try std.testing.expectEqual(0.0, circOut(@as(f32, 0.0)));
    try std.testing.expectEqual(0.8660254037844385965883020617184229, circOut(@as(f32, 0.5)));
    try std.testing.expectEqual(1.0, circOut(@as(f32, 1.0)));
}

/// Circular ease in followed by circular ease out.
pub fn circInOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    if (t < 0.5) {
        return (1.0 - @sqrt(@mulAdd(T, -4.0 * t, t, 1.0))) / 2.0;
    } else {
        const s = @mulAdd(T, -2.0, t, 2.0);
        return (@sqrt(@mulAdd(T, -s, s, 1)) + 1.0) / 2.0;
    }
}

test circInOut {
    try std.testing.expectEqual(0.0, circInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.066987306), circInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(0.5, circInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.9330127), circInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, circInOut(@as(f32, 1.0)));
}

pub const BackOptions = struct {
    /// Increasing this value increases the amount that the moves backwards before proceeding.
    back: f32 = 1.70158,
};

/// Easing that moves backwards slightly before moving in the correct direction.
///
/// One of Robert Penner's widely used easing functions.
pub fn backIn(t: anytype, opt: BackOptions) @TypeOf(t) {
    const T = @TypeOf(t);
    const t2 = t * t;
    const t3 = t2 * t;
    return @mulAdd(T, t3, opt.back, @mulAdd(T, -t2, opt.back, t3));
}

test backIn {
    try std.testing.expectEqual(0.0, backIn(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, -0.0641365625), backIn(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, -0.0876975), backIn(@as(f32, 0.5), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.1825903125), backIn(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, backIn(@as(f32, 1.0), .{}));
}

/// See `backIn`.
pub fn backOut(t: anytype, opt: BackOptions) @TypeOf(t) {
    const T = @TypeOf(t);
    const inv = t - 1;
    const inv2 = inv * inv;
    const inv3 = inv2 * inv;
    return @mulAdd(T, opt.back, inv3, @mulAdd(T, opt.back, inv2, inv3 + 1));
}

test backOut {
    try std.testing.expectEqual(0.0, backOut(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, 0.8174096875), backOut(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 1.0876975), backOut(@as(f32, 0.5), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 1.0641365624999999), backOut(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, backOut(@as(f32, 1.0), .{}));
}

/// Ease in back followed by ease out back.
pub fn backInOut(t: anytype, opt: BackOptions) @TypeOf(t) {
    const T = @TypeOf(t);
    const overshoot_adjusted = opt.back * 1.525;

    if (t < 0.5) {
        const a = 2 * t;
        const b = @mulAdd(T, overshoot_adjusted + 1, 2 * t, -overshoot_adjusted);
        return (a * a * b) / 2;
    } else {
        const a = @mulAdd(T, 2, t, -2);
        const b = @mulAdd(T, overshoot_adjusted + 1, @mulAdd(T, t, 2, -2), overshoot_adjusted);
        return @mulAdd(T, a * a, b, 2) / 2;
    }
}

test backInOut {
    try std.testing.expectEqual(0.0, backInOut(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, -0.09968184), backInOut(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectEqual(@as(f32, 0.5), backInOut(@as(f32, 0.5), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, 1.0996819), backInOut(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, backInOut(@as(f32, 1.0), .{}));
}

pub const ElasticOptions = struct {
    /// If less than one, overshoots before arriving. Less than one has no effect.
    amplitude: f32 = 1.0,
    /// The period of the oscillation.
    period: f32 = 0.3,
};

/// Elastic easing.
///
/// One of Robert Penner's widely used elastic easing function.
pub fn elasticIn(t: anytype, opt: ElasticOptions) @TypeOf(t) {
    if (t >= 1.0) return 1.0;
    if (t <= 0.0) return 0.0;

    var a = opt.amplitude;
    var m: f32 = pi / 4.0;
    if (a <= 1.0) {
        a = 1.0;
        m = opt.period / 4;
    } else {
        m = opt.period / (2 * pi) * std.math.asin(1 / a);
    }

    return -a * std.math.pow(@TypeOf(t), 2, @mulAdd(@TypeOf(t), 10, t, -10)) * @sin(
        (t - 1 - m) * 2 * pi / opt.period,
    );
}

test elasticIn {
    try std.testing.expectEqual(0.0, elasticIn(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, -0.005524), elasticIn(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, -0.015625), elasticIn(@as(f32, 0.5), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0883882), elasticIn(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, elasticIn(@as(f32, 1.0), .{}));
}

/// See `elasticIn`.
pub fn elasticOut(t: anytype, opt: ElasticOptions) @TypeOf(t) {
    return reverse(elasticIn, t, .{opt});
}

test elasticOut {
    try std.testing.expectEqual(0.0, elasticOut(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, 0.911611), elasticOut(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 1.015625), elasticOut(@as(f32, 0.5), .{}), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 1.005524), elasticOut(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, elasticOut(@as(f32, 1.0), .{}));
}

/// Elastic ease in followed by elastic ease out.
pub fn elasticInOut(t: anytype, opt: ElasticOptions) @TypeOf(t) {
    return mirror(elasticIn, t, .{opt});
}

test elasticInOut {
    try std.testing.expectEqual(0.0, elasticInOut(@as(f32, 0.0), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, -0.007812), elasticInOut(@as(f32, 0.25), .{}), 0.001);
    try std.testing.expectEqual(@as(f32, 0.5), elasticInOut(@as(f32, 0.5), .{}));
    try std.testing.expectApproxEqAbs(@as(f32, 1.0078125), elasticInOut(@as(f32, 0.75), .{}), 0.001);
    try std.testing.expectEqual(1.0, elasticInOut(@as(f32, 1.0), .{}));
}

/// Bounces with increasing magnitude until reaching the target.
///
/// One of Robert Penner's widely used easing functions.
pub fn bounceIn(t: anytype) @TypeOf(t) {
    return reverse(bounceOut, t, .{});
}

test bounceIn {
    try std.testing.expectEqual(0.0, bounceIn(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.02734375), bounceIn(@as(f32, 0.25)), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.234375), bounceIn(@as(f32, 0.5)), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.52734375), bounceIn(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, bounceIn(@as(f32, 1.0)));
}

/// See `bounceIn`.
pub fn bounceOut(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const a = 7.5625;
    const b = 2.75;

    if (t < 1.0 / b) {
        return a * t * t;
    } else if (t < 2.0 / b) {
        const t2 = t - 1.5 / b;
        return @mulAdd(T, a, t2 * t2, 0.75);
    } else if (t < 2.5 / b) {
        const t2 = t - 2.25 / b;
        return @mulAdd(T, a, t2 * t2, 0.9375);
    } else {
        const t2 = t - 2.625 / b;
        return @mulAdd(T, a, t2 * t2, 0.984375);
    }
}

test bounceOut {
    try std.testing.expectEqual(0.0, bounceOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.47265625), bounceOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.765625), bounceOut(@as(f32, 0.5)), 0.001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.97265625), bounceOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, bounceOut(@as(f32, 1.0)));
}

/// Bounce in followed by bounce out.
pub fn bounceInOut(t: anytype) @TypeOf(t) {
    return mirror(bounceIn, t, .{});
}

test bounceInOut {
    try std.testing.expectEqual(0.0, bounceInOut(@as(f32, 0.0)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.1171875), bounceInOut(@as(f32, 0.25)), 0.001);
    try std.testing.expectEqual(@as(f32, 0.5), bounceInOut(@as(f32, 0.5)));
    try std.testing.expectApproxEqAbs(@as(f32, 0.8828125), bounceInOut(@as(f32, 0.75)), 0.001);
    try std.testing.expectEqual(1.0, bounceInOut(@as(f32, 1.0)));
}

/// Smoothstep is a popular default easing function that eases in and out.
///
/// It can be derived by solving for the coefficients of a cubic equation that passes through (0, 0)
/// and (1, 1) with first derivatives of 0 at both points.
///
/// Mathematically equivalent to `mix(cubicIn, cubicOut, t)`, but slightly more performant.
pub fn smoothstep(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    return t * t * @mulAdd(T, -2.0, t, 3.0);
}

test smoothstep {
    try std.testing.expectEqual(0.0, smoothstep(@as(f32, 0.0)));
    try std.testing.expectEqual(mix(cubicIn, cubicOut, 0.25), smoothstep(@as(f32, 0.25)));
    try std.testing.expectEqual(0.5, smoothstep(@as(f32, 0.5)));
    try std.testing.expectEqual(mix(cubicIn, cubicOut, 0.75), smoothstep(@as(f32, 0.75)));
    try std.testing.expectEqual(1.0, smoothstep(@as(f32, 1.0)));
}

/// Smootherstep is a popular improvement to smoothstep popularized by Ken Perlin, and a slightly
/// better default if you don't mind mildly heavier computation.
///
/// It can be derived the same way as smoothstep, but you start with a quintic equation and require
/// both the first *and second* derivatives to 0 at the start and end points, creating a smoother
/// curve.
pub fn smootherstep(t: anytype) @TypeOf(t) {
    const T = @TypeOf(t);
    const t3 = t * t * t;
    const t4 = t3 * t;
    const t5 = t4 * t;
    return @mulAdd(T, 6, t5, @mulAdd(T, -15.0, t4, 10.0 * t3));
}

test smootherstep {
    try std.testing.expectEqual(0.0, smootherstep(@as(f32, 0.0)));
    try std.testing.expectEqual(0.103515625, smootherstep(@as(f32, 0.25)));
    try std.testing.expectEqual(0.5, smootherstep(@as(f32, 0.5)));
    try std.testing.expectEqual(0.8964844, smootherstep(@as(f32, 0.75)));
    try std.testing.expectEqual(1.0, smootherstep(@as(f32, 1.0)));
}

pub const StepOptions = struct {
    /// The number of in between steps to take.
    count: f32,
};

/// An ease function that steps by fixed amounts. Starts on the first step which is already past
/// zero, ends at 1 which is immediately after the last step.
pub fn step(t: anytype, opt: StepOptions) @TypeOf(t) {
    return @floor(opt.count * t + 1) / (opt.count + 1);
}

test step {
    const exc: StepOptions = .{ .count = 2 };
    try std.testing.expectEqual(@as(f32, 0.0), step(@as(f32, -0.1), exc));
    try std.testing.expectEqual(@as(f32, 1.0 / 3.0), step(@as(f32, 0.0), exc));
    try std.testing.expectEqual(@as(f32, 1.0 / 3.0), step(@as(f32, 0.0), exc));
    try std.testing.expectEqual(@as(f32, 1.0 / 3.0), step(@as(f32, 0.4), exc));
    try std.testing.expectEqual(@as(f32, 2.0 / 3.0), step(@as(f32, 0.5), exc));
    try std.testing.expectEqual(@as(f32, 2.0 / 3.0), step(@as(f32, 0.7), exc));
    try std.testing.expectEqual(@as(f32, 1.0), step(@as(f32, 1.0), exc));
}

/// Mixes two easing functions by linear interpolation. This is an alternative to `mirror`.
pub fn mix(in: anytype, out: anytype, t: anytype) @TypeOf(t) {
    return lerp(in(t), out(t), t);
}

test mix {
    try std.testing.expectEqual(0.0, mix(quadIn, quadOut, 0.0));
    try std.testing.expectEqual(0.15625, mix(quadIn, quadOut, 0.25));
    try std.testing.expectEqual(0.5, mix(quadIn, quadOut, 0.5));
    try std.testing.expectEqual(0.84375, mix(quadIn, quadOut, 0.75));
    try std.testing.expectEqual(1.0, mix(quadIn, quadOut, 1.0));
}

/// Reverses an easing function. Ease in functions become ease out functions, ease out functions
/// become ease in functions.
pub fn reverse(f: anytype, t: anytype, args: anytype) @TypeOf(t) {
    return 1.0 - @call(.auto, f, .{1.0 - t} ++ args);
}

test reverse {
    try std.testing.expectEqual(quadOut(@as(f32, 0.0)), reverse(quadIn, @as(f32, 0.0), .{}));
    try std.testing.expectEqual(quadOut(@as(f32, 0.25)), reverse(quadIn, @as(f32, 0.25), .{}));
    try std.testing.expectEqual(quadOut(@as(f32, 0.5)), reverse(quadIn, @as(f32, 0.5), .{}));
    try std.testing.expectEqual(quadOut(@as(f32, 0.75)), reverse(quadIn, @as(f32, 0.75), .{}));
    try std.testing.expectEqual(quadOut(@as(f32, 1.0)), reverse(quadIn, @as(f32, 1.0), .{}));
}

/// Mirrors an easing in function to create an in out function. This is an alternative to `mix`.
pub fn mirror(f: anytype, t: anytype, args: anytype) @TypeOf(t) {
    if (t < 0.5) {
        return @call(.auto, f, .{2 * t} ++ args) / 2.0;
    } else {
        return 1 - @call(.auto, f, .{@mulAdd(@TypeOf(t), -2, t, 2)} ++ args) / 2.0;
    }
}

test mirror {
    try std.testing.expectEqual(cubicInOut(@as(f32, 0.0)), mirror(cubicIn, @as(f32, 0.0), .{}));
    try std.testing.expectEqual(cubicInOut(@as(f32, 0.25)), mirror(cubicIn, @as(f32, 0.25), .{}));
    try std.testing.expectEqual(cubicInOut(@as(f32, 0.5)), mirror(cubicIn, @as(f32, 0.5), .{}));
    try std.testing.expectEqual(cubicInOut(@as(f32, 0.75)), mirror(cubicIn, @as(f32, 0.75), .{}));
    try std.testing.expectEqual(cubicInOut(@as(f32, 1.0)), mirror(cubicIn, @as(f32, 1.0), .{}));
}

/// Accelerates the `in` and `out` easing functions by two times, follows the first with the second.
pub fn combine(in: anytype, in_args: anytype, out: anytype, out_args: anytype, t: f32) @TypeOf(t) {
    if (t < 0.5) {
        return @call(.auto, in, .{2 * t} ++ in_args) / 2.0;
    } else {
        return (1.0 + @call(.auto, out, .{2 * t - 1} ++ out_args)) / 2.0;
    }
}

test combine {
    try std.testing.expectEqual(
        cubicInOut(@as(f32, 0.0)),
        combine(cubicIn, .{}, cubicOut, .{}, @as(f32, 0.0)),
    );
    try std.testing.expectEqual(
        cubicInOut(@as(f32, 0.25)),
        combine(cubicIn, .{}, cubicOut, .{}, @as(f32, 0.25)),
    );
    try std.testing.expectEqual(
        cubicInOut(@as(f32, 0.5)),
        combine(cubicIn, .{}, cubicOut, .{}, @as(f32, 0.5)),
    );
    try std.testing.expectEqual(
        cubicInOut(@as(f32, 0.75)),
        combine(cubicIn, .{}, cubicOut, .{}, @as(f32, 0.75)),
    );
    try std.testing.expectEqual(
        cubicInOut(@as(f32, 1.0)),
        combine(cubicIn, .{}, cubicOut, .{}, @as(f32, 1.0)),
    );
}
