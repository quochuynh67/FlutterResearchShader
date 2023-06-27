#include <flutter/runtime_effect.glsl>

const vec2 center = vec2(.5, .5);

uniform float time;
uniform vec3 resolution;
uniform sampler2D cat;

out vec4 fragColor;

// https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Twirl-Node.html
vec2 twirl(vec2 uv, vec2 center, float strength) {
  vec2 uv_cen = uv - center;
  float scaled_dist = strength * length(uv_cen);
  vec2 cs = vec2(cos(scaled_dist), sin(scaled_dist));

  float x_twirl = dot(cs * vec2(1.0, -1.0), uv_cen);
  float y_twirl = dot(cs.yx, uv_cen);

  return vec2(x_twirl + center.x, y_twirl + center.y);
}

void main(void) {
  float modt = mod(time, 2);
  float modi = min(2 - modt, modt) - 0.5;
  vec2 uv = FlutterFragCoord().xy/resolution.xy;
  fragColor = texture(cat, twirl(uv,center,modi));
  fragColor.r = fragColor.r * (modi / 2.);
  fragColor.b = fragColor.b * (1. - (modi / 2.));
}
