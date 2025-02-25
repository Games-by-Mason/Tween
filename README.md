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

The following easing functions are supported, most of these originated with [Robert Penner](http://robertpenner.com/easing/):

* linear
* [sine](https://easings.net/#easeInSine)
* [quad](https://easings.net/#easeInQuad)
* [cubic](https://easings.net/#easeInCubic)
* [quart](https://easings.net/#easeInQuart)
* [quint](https://easings.net/#easeInQuint)
* [exp](https://easings.net/#easeInExpo)
* [circ](https://easings.net/#easeInCirc)
* [back](https://easings.net/#easeInBack)
* [elastic](https://easings.net/#easeInElastic)
* [bounce](https://easings.net/#easeInBounce)
* step
* [smoothstep](https://en.wikipedia.org/wiki/Smoothstep)
* [smootherstep](https://en.wikipedia.org/wiki/Smoothstep#Variations)

I've opted to not include GIFs demonstrating the easing styles here, as [easings.net](https://easings.net) already has a great visualizer for almost all of these.

(Note that the links above are provided for convenient reference, the actual implementations may not be 100% identical or may have slightly different parameters.)

In, out, and in-out variations of each are provided, functions are exact at 0 and 1 for 32 bit floats unless otherwise noted.

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
