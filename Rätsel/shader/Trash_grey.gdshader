shader_type canvas_item;




void fragment() {
    // Scale UV coordinates to sample from center at half size
    vec2 centered_uv = (UV - 0.5) * 2.0 + 0.5;// UV geht jetzt von -0.5 bis 1.5, nimmt aber denselben Platz ein.
	// Wenn wir alles außerhalb von 0 bis 1 rausschneiden, erhalten wir das Originalbild welches jetzt die Hälfte des Platzes einnimmt.

    // Discard pixels outside the scaled area
    if (centered_uv.x < 0.0 || centered_uv.x > 1.0 ||
        centered_uv.y < 0.0 || centered_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        // Sample the texture at the scaled UV
        vec4 tex_color = texture(TEXTURE, centered_uv);

        // Convert to greyscale using luminosity method
        float grey = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

        // Apply greyscale while preserving alpha
        COLOR = vec4(vec3(grey), tex_color.a);
    }
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
