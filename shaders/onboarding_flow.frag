#version 460 core

#include <flutter/runtime_effect.glsl>

// Posterised, pixelated, grainy flowing gradient used behind onboarding.
// Everything except the grain is evaluated once per "cell" (a coarse pixel).

uniform vec2 uSize;
uniform float uPhase; // 0..2π, loops seamlessly

out vec4 fragColor;

const float CELLS_ACROSS = 64.0;
const float LEVELS = 26.0;

float bayer2(vec2 a) {
  a = floor(a);
  return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

float bayer4(vec2 a) {
  return bayer2(0.5 * a) * 0.25 + bayer2(a);
}

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

vec3 stop(vec3 base, vec3 target, float a, float b, float r) {
  return mix(base, target, clamp((r - a) / (b - a), 0.0, 1.0));
}

vec3 ramp(float r) {
  vec3 c = vec3(0.973, 0.294, 0.149);
  c = stop(c, vec3(0.824, 0.275, 0.141), 0.00, 0.14, r);
  c = stop(c, vec3(0.635, 0.341, 0.314), 0.14, 0.20, r);
  c = stop(c, vec3(0.522, 0.345, 0.333), 0.20, 0.25, r);
  c = stop(c, vec3(0.169, 0.129, 0.129), 0.25, 0.30, r);
  c = stop(c, vec3(0.098, 0.098, 0.086), 0.30, 0.35, r);
  c = stop(c, vec3(0.102, 0.102, 0.102), 0.35, 0.48, r);
  c = stop(c, vec3(0.106, 0.125, 0.157), 0.48, 0.52, r);
  c = stop(c, vec3(0.141, 0.208, 0.255), 0.52, 0.56, r);
  c = stop(c, vec3(0.157, 0.224, 0.271), 0.56, 0.62, r);
  c = stop(c, vec3(0.255, 0.286, 0.341), 0.62, 0.68, r);
  c = stop(c, vec3(0.490, 0.306, 0.384), 0.68, 0.72, r);
  c = stop(c, vec3(0.545, 0.314, 0.384), 0.72, 0.78, r);
  c = stop(c, vec3(0.627, 0.400, 0.455), 0.78, 0.84, r);
  c = stop(c, vec3(0.537, 0.361, 0.404), 0.84, 0.88, r);
  c = stop(c, vec3(0.341, 0.333, 0.373), 0.88, 0.93, r);
  c = stop(c, vec3(0.184, 0.216, 0.259), 0.93, 0.97, r);
  c = stop(c, vec3(0.106, 0.122, 0.153), 0.97, 1.00, r);
  return c;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float cell = max(uSize.x / CELLS_ACROSS, 1.0);
  vec2 cellIdx = floor(frag / cell);
  vec2 p = (cellIdx + 0.5) * cell / uSize.x;

  // Diagonal flow: position across the bands plus slow, looping warping.
  float angle = 0.80 - 0.17 * sin(uPhase + 0.6);
  vec2 n = vec2(cos(angle), sin(angle));
  float across = dot(p, n);
  float along = dot(p, vec2(-n.y, n.x));
  float shift = -0.10 * sin(uPhase + 0.6);
  float warp = 0.06 * sin(2.4 * along + uPhase)
      + 0.03 * sin(5.3 * along - 2.0 * uPhase + 1.3)
      + 0.02 * sin(4.0 * p.x + 3.0 * p.y + uPhase + 2.0);
  float r = 0.6 * (across + shift + warp) + 0.04;

  // Ordered dithering between posterised levels gives the checkered edges.
  float d = bayer4(cellIdx) - 0.5;
  float rq = floor(r * LEVELS + d * 0.45 + 0.5) / LEVELS;

  vec3 color = ramp(clamp(rq, 0.0, 1.0));

  // More contrast, slightly darker overall.
  color = clamp((color - 0.3) * 1.3 + 0.3, 0.0, 1.0);
  color *= 0.82;

  // Static, blocky grain: coarser than a pixel, finer than a cell.
  float grain = hash(floor(frag / (cell / 3.0))) - 0.5;
  color += grain * 0.05;

  fragColor = vec4(color, 1.0);
}
