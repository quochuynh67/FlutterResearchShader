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
//////////////// Shadertoy BEGIN

// Credit: mrange @ shadertoy
// https://www.shadertoy.com/view/ctBSRR

#define TIME        iTime
#define RESOLUTION  iResolution

float df(vec2 p) {
  const float m = 0.25;
  float l = length(p);
  l = mod(l+(0.5*m), m)-(0.5*m);
  return abs(l)-(m*0.25);
}

// License: MIT, author: Inigo Quilez, found: https://www.iquilezles.org/www/articles/smin/smin.htm
float pmin(float a, float b, float k) {
  float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0-h);
}

// License: CC0, author: Mårten Rånge, found: https://github.com/mrange/glsl-snippets
float pmax(float a, float b, float k) {
  return -pmin(-a, -b, k);
}

vec3 effect(vec2 p, vec2 pp) {
  float aa = 2.0/RESOLUTION.y;
  float tm = TIME*0.3;
  vec2 p0 = p+sin(vec2(1.0, sqrt(0.5))*(tm+100.0));
  vec2 p1 = p+sin(1.2*vec2(1.0, sqrt(0.5))*(tm+200.0));
  float sm = 0.0666*length(p);
  float d0 = df(p0);
  float d1 = df(p1);
  float d = d0;
  d = pmax(d, d1, sm);
  float dd = -d0;
  dd = pmax(dd, -d1, sm);
  d =  min(d, dd);
  const float so = 8.0;
  const float co = 0.5;
  vec3 bcol0 = (1.0+sin(vec3(0.0, 1.0, 2.0) + co*length(p0)+1.0-TIME))/(so*dot(p0, p0)+0.0001);
  vec3 bcol1 = (1.0+sin(vec3(0.0, 1.0, 2.0) + co*length(p1)+3.0+TIME))/(so*dot(p1, p1)+0.0001);
  vec3 bcol = (bcol0+bcol1);
  vec3 col = vec3(0.0);
  col += 0.005*bcol/(max(dd+0.005, 0.0)+0.0001);
  col = mix(col, bcol, smoothstep(aa, -aa, d));
  col -= 0.25*vec3(0.0, 1.0, 2.0).zyx*length(pp);
  col *= smoothstep(1.5, 0.5, length(pp));
  col = clamp(col, 0.0, 1.0);
  col = sqrt(col);
  return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 q = fragCoord/RESOLUTION.xy;
  vec2 p = -1. + 2. * q;
  vec2 pp = p;
  p.x *= RESOLUTION.x/RESOLUTION.y;
  vec3 col = effect(p, pp);

  fragColor = vec4(col, 1.0);
}

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
