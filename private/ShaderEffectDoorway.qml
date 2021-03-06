import QtQuick 2.0

/*
 * Source code from: http://transitions.glsl.io/
 * http://transitions.glsl.io/transition/979934722820b5e715fa by gre
 */

ShaderEffect {
    anchors.fill: parent

    property variant srcSampler: textureSource
    property variant dstSampler: textureDestination

    property real progress: 0.0
    property real reflection: 0.4
    property real perspective: 0.4
    property real depth: 2

    property bool forward: true

    fragmentShader: "
uniform sampler2D srcSampler;
uniform sampler2D dstSampler;
uniform float progress;
uniform bool forward;

varying highp vec2 qt_TexCoord0;

const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 boundMin = vec2(0.0, 0.0);
const vec2 boundMax = vec2(1.0, 1.0);

uniform float reflection;
uniform float perspective;
uniform float depth;

bool inBounds (vec2 p) {
  return all(lessThan(boundMin, p)) && all(lessThan(p, boundMax));
}

vec2 project (vec2 p) {
  return p * vec2( 1.0, 2.0-p.y ) + vec2(0.0, 0.001);
}

vec4 bgColor (vec2 pto) {
  vec4 c = black;
  pto = project(pto);
  if (inBounds(pto)) {
    vec4 rfl = forward ? texture2D(dstSampler, pto) : texture2D(srcSampler, pto);
    c += mix(black, rfl, reflection * mix(1.0, 0.0, 1.0-pto.y));
  }
  return c;
}


void main() {
    vec2 pfr = vec2(-1.0, -1.0);
    vec2 pto = vec2(-1.0, -1.0);
    float pr = forward ? progress : (1.0-progress);

    float middleSlit = 2.0 * abs(qt_TexCoord0.x-0.5) - pr;
    if (middleSlit > 0.0) {
        pfr = qt_TexCoord0 + (qt_TexCoord0.x > 0.5 ? -1.0 : 1.0) * vec2(0.5*pr, 0.0);
        float d = 1.0/(1.0+perspective*pr*(1.0-middleSlit));
        pfr.y -= d/2.;
        pfr.y *= d;
        pfr.y += d/2.;
    }

    float size = mix(1.0, depth, 1.0-pr);
    pto = (qt_TexCoord0 + vec2(-0.5, -0.5)) * vec2(size, size) + vec2(0.5, 0.5);

    if (inBounds(pfr)) {
        gl_FragColor = forward ? texture2D(srcSampler, pfr) : texture2D(dstSampler, pfr);
    }
    else if (inBounds(pto)) {
        gl_FragColor = forward ? texture2D(dstSampler, pto) : texture2D(srcSampler, pto);
    }
    else {
        gl_FragColor = bgColor(pto);
    }
}
"

}

