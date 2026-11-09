// Shared by afterimage.gdshader and afterimage_add.gdshader.
uniform int mode : hint_range(0, 2) = 1;   // 0 normal, 1 tint, 2 silhouette
uniform vec4 tint : source_color = vec4(0.45, 0.75, 1.0, 0.7);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	// the sprite's own modulate (inherited): NORMAL copies match the sprite, and every
	// look fades with it
	vec3 rgb = tex.rgb * COLOR.rgb;
	if (mode == 1) {
		// keep the sprite's shading, in the tint colour
		float l = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
		rgb = tint.rgb * (0.35 + 0.9 * l);
	} else if (mode == 2) {
		rgb = tint.rgb;
	}
	COLOR = vec4(rgb, tex.a * tint.a * COLOR.a);
}
