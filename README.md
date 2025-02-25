# Tween

Rigid motion often appears unnatural. This library provides easing and interpolation functions widely used in game development to create natural looking or stylized tweens ("inbetweens").

Example usage:
```zig
const tween = @import("tween");
const lerp = tween.interp.lerp;
const ease = tween.ease;

// ...

pos = lerp(start, end, ease.bounceOut(t));
```

## Interpolation

The following interpolation functions are provided:
* `lerp`
* `ilerp`
* `remap`
* `clamp01`
* `damp`

Linear interpolation differs from the implementation in the standard library in that it returns exact results at 0 and 1.

Additionally, it accepts a larger variety of types:
* Floats
* Vectors
* Arrays
* Structures containing other supported types

`ilerp` is the inverse of `lerp`, and only accepts floats. `remap` uses a combination of `ilerp` and `lerp` to remap a value from one range to another.

`clamp01` is what it sounds like, and is provided for convenience. You can apply it to a `t` value getting passed to `lerp` to create a clamped lerp.

`damp` is useful for [framerate independent lerping](https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/).

If you're unfamiliar with this class of functions, I recommend viewing [The Simple Yet Powerful Math We Don't Talk About](https://www.youtube.com/watch?v=NzjF1pdlK7Y) by [Freya Holmer](https://www.acegikmo.com/).

## Ease

Most popular easing styles are supported, including the widely used easing styles popularized by [Robert Penner](http://robertpenner.com/easing/). [easings.net] is a good reference for most of these, but keep in mind that the implementations may vary.

Easing functions operate on the `t` value given to `lerp`. For example:
```zig
const result = lerp(a, b, ease.smootherstep(t));
```

If you're new to easing and not sure which to use, `smootherstep` is a reasonable default to slap on everything to start.

You can adapt easing functions with `mix`, `combine`, `reflect`, and `reverse`.

The provided easing functions are exact at 0 and 1 for 32 bit floats unless otherwise noted.

When designing your own easing functions, I highly recommend testing them in [Desmos](https://www.desmos.com/calculator).

## Build Configuration

If you're shipping binaries, you probably have a min spec CPU in mind. I recommend making sure `muladd` is enabled for your baseline so it doesn't end up getting emulated in software, [more info here](https://gamesbymason.com/devlog/2025/#muladd). On x86 this means enabling `fma`, on arm/aarch64 this means enabling either `neon` or `vfp4`.
