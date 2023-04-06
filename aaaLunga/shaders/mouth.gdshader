shader_type spatial;
uniform sampler2D filter_off : source_color, filter_nearest;
uniform float offset;


void fragment() {
// Input:2
	vec2 UvOffset = vec2(UV.x + (offset * 42.0) / 966.0, UV.y);


// Texture2D:3
	vec4 n_out3p0 = texture(filter_off, UvOffset);


// Output:0
	ALBEDO = vec3(n_out3p0.xyz);


}
