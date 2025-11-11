//! Composable easing an interpolation functions.
//!
//! Rigid motion often appears unnatural. This library provides easing and interpolation functions
//! widely used in game development to create natural looking or stylized tweens ("inbetweens").
//!
//! Example usage:
//! ```zig
//! const tween = @import("tween");
//! const lerp = tween.interp.lerp;
//! const ease = tween.ease;
//! 
//! // ...
//! 
//! pos = lerp(start, end, ease.bounceOut(t));
//! ```

const std = @import("std");
const builtin = @import("builtin");

pub const ease = @import("ease.zig");
pub const interp = @import("interp.zig");

test {
    std.testing.refAllDecls(@This());
}
