//! Composable easing an interpolation functions.

const std = @import("std");
const builtin = @import("builtin");

pub const ease = @import("ease.zig");
pub const interp = @import("interp.zig");

test {
    std.testing.refAllDecls(@This());
}
