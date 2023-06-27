#include <flutter/runtime_effect.glsl>
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform vec4 iMouse;
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
/* Shadertoy BEGIN */

const vec2 center = vec2(.5, .5);

float angler(vec2 uv, float closeness, float tmod, float slices) {
  float slice = 3.142 / slices;
  float angle = atan(uv.y - center.y, uv.x - center.x);
  float amod = mod(angle + ((iTime + 421.88) * tmod), slice);

  return min(
    smoothstep((slice / 4.), slice, amod),
    smoothstep(slice, (slice / 4.), amod)
  ) * closeness;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    float closeness = 1. - distance(center, uv);

    float av1 = angler(uv, closeness, -0.05, 8.);
    av1 += angler(uv, closeness, .09, 6.);
    av1 -= angler(uv, closeness, -0.08, 7.);
    av1 -= angler(uv, closeness, 0.02, 9.);
    av1 += closeness;

    float focus = pow(closeness, 10.);
    float trand = 0.6 + (abs(cos(iTime * 0.2)) * 0.4);

    fragColor = vec4(
      pow(av1, 2.),
      pow(av1, 1.5),
      pow(av1, 1.1),
      1.
    ) * focus + focus;
}

/* Shadertoy END */
void main(void) { mainImage(fragColor, FlutterFragCoord()); }

