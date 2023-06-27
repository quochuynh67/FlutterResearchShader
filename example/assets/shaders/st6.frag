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

// Credit: tve @ shadertoy
// https://www.shadertoy.com/view/dtlSRl

#define NLAYERS 32.0

float hash(vec2 p) {
    p = fract(p * vec2(sin(123.124), sin(928.0123)));
    p += dot(p,p+154.23);
    return fract(p.x*p.y);
}

vec3 draw_star(vec2 uv, float intensity) {

    float d = length(uv);
    vec3 col = vec3(0);
    col += 0.3/pow(d,2.0);
    col.b *= 4.0;
    col *= intensity;
    col *= smoothstep(0.5, 0.2, d);
    return col;
}

vec3 star_field(vec2 uv, float intensity) {
   vec2 gv = fract(uv)-0.5;
   vec2 id = floor(uv);

   vec3 col = vec3(0);

   for(int y=-1;y<=1;y++) {
     for(int x=-1;x<=1;x++) {
       vec2 offs = vec2(x,y);
       float n = hash(id+offs);

       col += draw_star(gv-offs-vec2(n-0.5,fract(n*34.0))+0.5, intensity);

     }
   }
   return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 uv = (fragCoord-0.5*iResolution.xy)/iResolution.y;


   vec3 col = vec3(0);


   for( float i=0.0;i<1.0;i+= 1.0/NLAYERS) {
       float t = iTime*0.1;
       float depth = fract(i+t);
       float scale = mix(10., 0.1, depth);
       col += star_field(uv*scale+i*4000.0, pow(i*.001, 1.0+i*0.5) );
   }


   fragColor = vec4(col,1.0);
}

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
