#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform sampler2D sampler1;
uniform sampler2D sampler2;
uniform float transitionValue;
uniform vec3 resolution;

out vec4 fragColor;

void main() {

  vec2 uv = FlutterFragCoord().xy/resolution.xy;
  vec4 color1 = texture(sampler1, uv);
  vec4 color2 = texture(sampler2, uv);

  // Apply transition effect using the transitionValue
  vec4 finalColor = mix(color1, color2, transitionValue);

  fragColor = finalColor;
}