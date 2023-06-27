#include <flutter/runtime_effect.glsl>

uniform float time;
uniform vec3 resolution;
uniform vec2 input_uv;
uniform float intensity;

const vec2 base = vec2(.5, .5);
const vec2 p1 = vec2(.24, .18);
const vec2 p2 = vec2(-.15, -.34);
const vec2 p3 = vec2(-.33, .24);

out vec4 fragColor;
void main()
{
  vec2 uv = (FlutterFragCoord()/resolution.xy);
  vec2 ibase = mix(base, input_uv, intensity);

  vec2 d1 = mix(
    ibase + vec2(p1.x * cos(time * .31), p1.y * sin(time * .31)),
    input_uv,
    intensity
  );

  vec2 d2 = mix(
    base + vec2(
      p2.x * cos(time * .26),
      p2.y * sin(time * .26)
    ),
    input_uv,
    intensity
  );

  vec2 d3 = mix(
    base + vec2(
      p3.x * cos(time * .24),
      p3.y * sin(time * .24)
    ),
    input_uv,
    intensity
  );

  float value  = ((distance(uv, d1) + distance(uv, d2) + distance(uv, d3)) / 3.);
  value = min(smoothstep(.2, .3, value), smoothstep(.3, .2, value));

  vec3 vvalue = vec3(
    pow(value, 2.),
    pow(value, 3.),
    pow(value, 3.)
  );

  fragColor = vec4(vvalue, 1.);
}