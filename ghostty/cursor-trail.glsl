// Ghostty Cursor Trail Shader
// Emulates Kitty's cursor_trail N effect using Ghostty's custom shader uniforms.
//
// The shader draws fading ghosts of the cursor at its previous position.
// Since Ghostty only provides one level of cursor history (iPreviousCursor),
// we simulate a multi-ghost trail by dividing the fade into discrete opacity
// steps that approximate Kitty's behavior with cursor_trail 3.
//
// Config:
//   custom-shader = ~/.config/ghostty/cursor-trail.glsl
//   custom-shader-animation = true

// ---- Configuration tunables ----

// Number of visible ghost steps in the trail (like Kitty's cursor_trail N).
// Higher values spread the fade across more steps. Since we only have one
// previous cursor position, this controls the stepping resolution of the
// single ghost's fade-out, not distinct historical positions.
#define TRAIL_STEPS      3.0

// How long (seconds) the full trail is visible after the cursor moves.
#define TRAIL_DURATION   0.45

// Maximum opacity of the brightest ghost. Higher = more visible trail.
#define MAX_TRAIL_ALPHA  0.45

// Minimum cursor movement in cells to trigger the trail.
// Matches Kitty's cursor_trail_start_threshold — avoids noise from
// small cursor adjustments (IME, shell suggestion widgets, etc.).
#define START_THRESHOLD  20.0


// ---- Shader entry point ----

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 color = texture(iChannel0, uv);

    // Respect cursor visibility (hidden during blink, inactive terminal, etc.)
    if (iCursorVisible.x > 0.5) {
        float dt = iTime - iTimeCursorChange;

        if (dt > 0.001 && dt < TRAIL_DURATION) {
            // Previous cursor rect: corner (x,y), size (z,w)
            vec2 prevPos = iPreviousCursor.xy;
            vec2 prevSize = iPreviousCursor.zw;

            // Guard against zero-size cursor (no valid previous state)
            if (prevSize.x > 0.0 && prevSize.y > 0.0) {
                // Compute how many cells the cursor moved (minimum of w/h as cell size)
                float cellSize = min(prevSize.x, prevSize.y);
                vec2 deltaPx = iCurrentCursor.xy - prevPos;
                float cellDist = length(deltaPx) / cellSize;

                // Only draw trail when cursor moved a meaningful distance
                if (cellDist >= START_THRESHOLD) {
                    // Is the current pixel inside the previous cursor rectangle?
                    vec2 rel = fragCoord - prevPos;
                    if (rel.x >= 0.0 && rel.x < prevSize.x &&
                        rel.y >= 0.0 && rel.y < prevSize.y) {

                        // Normalized time through the trail [0, 1]
                        float t = dt / TRAIL_DURATION;

                        // Step the fade into discrete ghost levels
                        float ghostStep = floor(t * TRAIL_STEPS) / TRAIL_STEPS;

                        // Opacity per step — decreases as ghosts age
                        float ghostAlpha = MAX_TRAIL_ALPHA * (1.0 - ghostStep);

                        // Use the cursor color from when it was at this position
                        vec3 ghostColor = iPreviousCursorColor.rgb;

                        // Blend — composite on top of terminal content
                        color.rgb = mix(color.rgb, ghostColor, ghostAlpha);
                    }
                }
            }
        }
    }

    fragColor = color;
}
