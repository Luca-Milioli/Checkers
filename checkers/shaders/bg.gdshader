shader_type canvas_item;

void vertex() {
    vec2 center = vec2(0.5); // centro della texture
    vec2 offset = UV - center;

    float angle = sin(TIME * 0.5) * 0.15; // rotazione oscillante in radianti

    // Matrice di rotazione 2D (corretta per Godot)
    mat2 rot = mat2(
        vec2(cos(angle), -sin(angle)),
        vec2(sin(angle),  cos(angle))
    );

    // Applica rotazione e riposiziona
    UV = rot * offset + center;

    // Scroll
    UV.x -= TIME * 0.05;
    UV.y -= TIME * 0.15;
}

