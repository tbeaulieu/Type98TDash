import QtQuick 2.3

// Endless grid of rounded tiles in perspective, scrolling right -> left, softly lit.
// Qt 5, OpenGL ShaderEffect. Same interface as TopoBackground, so you can swap them:
//
//   GridBackground { anchors.fill: parent; z: -1 }
//
// Colours should be opaque. Needs the OpenGL scene-graph backend.
ShaderEffect {
    id: grid

    // --- colours -------------------------------------------------------
    property color backColor:   "#06100c"   // gap colour, top
    property color backColor2:  "#030806"   // gap colour, bottom / fog / vignette
    property color tileColor:   "#1f3a2e"   // tile, lower half of gradient
    property color tileColor2:  "#142a20"   // tile, upper half of gradient
    property color edgeColor:   "#7fd0a5"   // rim light on tile edges
    property color accentColor: "#ffd400"   // the odd tile that glows

    // --- grid shape ----------------------------------------------------
    property real cells:     7              // tiles per screen height
    property real tileSize:  0.88           // fraction of the cell (rest = gap)
    property real radius:    0.20           // corner radius, cell units
    property real edgeWidth: 0.14           // soft bevel width

    // --- perspective ---------------------------------------------------
    property real tiltY: -0.35              // north/south: - = far at the top (floor), + = far at the bottom (ceiling)
    property real tilt:  0.0                // east/west:   + = far on the right, - = far on the left

    // --- light ---------------------------------------------------------
    property real lightX: 0.30
    property real lightY: 0.35
    property real lightStrength: 0.70
    property real lightFalloff:  1.6        // higher = tighter pool of light
    property real ambient:       0.45
    property real rimStrength:   0.35
    property real sheen:         0.12       // slow sweeping highlight (0 = off)
    property real sheenSpeed:    0.07

    // --- life ----------------------------------------------------------
    property real speed:        0.12        // screen-heights per second; 0 = frozen
    property real variation:    0.25        // per-tile brightness spread
    property real shimmer:      0.10
    property real accentChance: 0.035       // fraction of tiles using accentColor
    property real accentAmount: 0.55
    property real fog:          0.70
    property real vignette:     0.60

    property bool running: true

    // --- internals -----------------------------------------------------
    property real aspect: width / Math.max(1, height)
    property real time: 0
    NumberAnimation on time {
        running: grid.running && grid.visible
        from: 0; to: 3600; duration: 3600000
        loops: Animation.Infinite
    }

    blending: opacity < 1                    // opaque when fully shown (cheaper), blended while fading

    fragmentShader:
        "#ifdef GL_ES\n" +
        "#extension GL_OES_standard_derivatives : enable\n" +
        "#ifdef GL_FRAGMENT_PRECISION_HIGH\n" +
        "precision highp float;\n" +
        "#else\n" +
        "precision mediump float;\n" +
        "#endif\n" +
        "#endif\n" +
        "\n" +
        "varying highp vec2 qt_TexCoord0;\n" +
        "uniform lowp float qt_Opacity;\n" +
        "\n" +
        "uniform float time;\n" +
        "uniform float speed;\n" +
        "uniform float aspect;\n" +
        "uniform float cells;\n" +
        "uniform float tileSize;\n" +
        "uniform float radius;\n" +
        "uniform float edgeWidth;\n" +
        "uniform float tilt;\n" +
        "uniform float tiltY;\n" +
        "uniform float lightX;\n" +
        "uniform float lightY;\n" +
        "uniform float lightStrength;\n" +
        "uniform float lightFalloff;\n" +
        "uniform float ambient;\n" +
        "uniform float variation;\n" +
        "uniform float shimmer;\n" +
        "uniform float sheen;\n" +
        "uniform float sheenSpeed;\n" +
        "uniform float rimStrength;\n" +
        "uniform float accentChance;\n" +
        "uniform float accentAmount;\n" +
        "uniform float fog;\n" +
        "uniform float vignette;\n" +
        "uniform vec4 backColor;\n" +
        "uniform vec4 backColor2;\n" +
        "uniform vec4 tileColor;\n" +
        "uniform vec4 tileColor2;\n" +
        "uniform vec4 edgeColor;\n" +
        "uniform vec4 accentColor;\n" +
        "\n" +
        "float hash1(vec2 p) {\n" +
        "    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);\n" +
        "}\n" +
        "\n" +
        "void main() {\n" +
        "    vec2 uv = qt_TexCoord0;\n" +
        "\n" +
        "    // cheap perspective: scale the plane by a depth term that varies across the screen\n" +
        "    float w = 1.0 + tilt * (uv.x - 0.5) + tiltY * (uv.y - 0.5);\n" +
        "    vec2 p = (uv - 0.5) * vec2(aspect, 1.0) * w;\n" +
        "    p.x += time * speed;                        // sampling moves right, so the grid scrolls right -> left\n" +
        "\n" +
        "    vec2 g  = p * cells;\n" +
        "    vec2 id = mod(floor(g), 64.0);              // wrap ids so hashing stays precise\n" +
        "    vec2 f  = fract(g) - 0.5;\n" +
        "    float h = hash1(id);\n" +
        "\n" +
        "    // rounded-box distance (cell units): negative inside the tile\n" +
        "    vec2 q = abs(f) - vec2(tileSize * 0.5 - radius);\n" +
        "    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;\n" +
        "\n" +
        "#if defined(GL_ES) && !defined(GL_OES_standard_derivatives)\n" +
        "    float px = 0.03;                            // no derivatives: fixed-softness fallback\n" +
        "#else\n" +
        "    float px = max(fwidth(d), 0.0005);\n" +
        "#endif\n" +
        "    float a     = 1.0 - smoothstep(-px, px, d);          // tile coverage, antialiased\n" +
        "    float inner = smoothstep(0.0, edgeWidth, -d);        // 0 at the edge, 1 inside\n" +
        "\n" +
        "    // tile surface: vertical gradient, per-tile brightness, slow travelling shimmer\n" +
        "    vec3 base = mix(tileColor2.rgb, tileColor.rgb, f.y + 0.5);\n" +
        "    base *= 1.0 - variation * h;\n" +
        "    float wave = 0.5 + 0.5 * sin(id.x * 0.55 + id.y * 0.35 - time * 0.8);\n" +
        "    base *= 1.0 + shimmer * (wave - 0.5);\n" +
        "\n" +
        "    // a few tiles pick up the accent colour\n" +
        "    float acc = step(1.0 - accentChance, hash1(id + 17.0));\n" +
        "    base = mix(base, accentColor.rgb, acc * accentAmount);\n" +
        "\n" +
        "    // soft lighting: a pooled light source plus a slow sweeping sheen\n" +
        "    vec2 dl = (uv - vec2(lightX, lightY)) * vec2(aspect, 1.0);\n" +
        "    float L = exp(-dot(dl, dl) * lightFalloff);\n" +
        "    float sweepX = fract(time * sheenSpeed) * 1.8 - 0.4;\n" +
        "    float sx = (uv.x - sweepX) * 4.0;\n" +
        "    float light = ambient + lightStrength * L + sheen * exp(-sx * sx);\n" +
        "\n" +
        "    vec3 tile = base * light;\n" +
        "    tile += edgeColor.rgb * (1.0 - inner) * rimStrength * (0.4 + L);   // rim light on the bevel\n" +
        "\n" +
        "    vec3 bg = mix(backColor.rgb, backColor2.rgb, uv.y) * (0.7 + 0.5 * L);\n" +
        "    vec3 col = mix(bg, tile, a);\n" +
        "\n" +
        "    // depth fog toward the far side, then vignette\n" +
        "    float far = max(0.5 * (abs(tilt) + abs(tiltY)), 0.001);\n" +
        "    col = mix(col, backColor2.rgb, smoothstep(0.0, far, w - 1.0) * fog);\n" +
        "    float vig = smoothstep(0.3, 0.95, length((uv - 0.5) * vec2(1.3, 1.1)));\n" +
        "    col = mix(col, backColor2.rgb, vig * vignette);\n" +
        "\n" +
        "    gl_FragColor = vec4(col, 1.0) * qt_Opacity;\n" +
        "}\n" +
        "\n"
}
