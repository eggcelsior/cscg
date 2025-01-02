shader_type spatial;
//render_mode cull_disabled, wireframe;
uniform sampler2D temp_texture;

uniform sampler2D heightmap;
uniform float height_ratio = 1.0;

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * height_ratio;
}

void fragment() {
	ALBEDO = texture(temp_texture, UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
