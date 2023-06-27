#include <flutter/runtime_effect.glsl>

uniform float time;
uniform vec3 resolution;
uniform vec2 input_coord;
uniform float intensity;

vec2 c = vec2(.5, .5);

out vec4 fragColor;
void main()
{
    float mi = 0.6 + (intensity * 0.3);
    vec2 uv = (FlutterFragCoord()/resolution.xy);
    float tr = time + 113.4;
    float r1 = 1. - (sin(time * 2.3) / 60.);
    float r2 = 1. - (sin(time * 3.2) / 60.);

    vec2 p1 = c + vec2(sin(tr * 0.2) * 0.25, cos(tr * 0.3) * 0.21);
    vec2 p2 = c + vec2(cos(tr * 0.4) * 0.11, sin(tr * 0.1) * 0.14);
    vec2 p3 = c + vec2(sin(tr * 0.3) * 0.28, cos(tr * 0.2) * 0.24);

    float d1 = (1.-distance(uv, mix(p1, input_coord, intensity)))*r1;
    float d2 = (1.-distance(uv, mix(p2, input_coord, intensity)))*r2;
    float d3 = (1.-distance(uv, mix(p3, input_coord, intensity)))*r2;

    float dd1 = d1 - d2;
    float dd2 = d2 - d3;
    float dd3 = d3 - d1;

    fragColor = vec4(
        pow(d1, 10.) * mi + dd2 * 2,
        pow(d2, 13.) * mi + dd1 * 2,
        pow(d3, 15.) * mi + dd3 * 2,
        1.
    );
}