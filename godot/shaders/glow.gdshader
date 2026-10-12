shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, fog_disabled;
varying float kind;
void vertex() {
	kind = INSTANCE_CUSTOM.x;
	if (kind > 1.5) {
		VERTEX = vec3(VERTEX.x, VERTEX.z, 0.0) * INSTANCE_CUSTOM.y;
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
}
void fragment() {
	float a;
	if (kind < 0.5) {
		float al = UV.y;
		float lon = (al - 0.42) / 0.34;
		float lat = (UV.x - 0.5) / (0.1 + 0.32 * al);
		a = exp(-lon * lon) * exp(-lat * lat * 1.6);
	} else if (kind < 1.5) {
		float r = length(UV - 0.5) * 2.0;
		a = pow(clamp(1.0 - r, 0.0, 1.0), 2.0);
	} else {
		float r = length(UV - 0.5) * 2.0;
		a = pow(clamp(1.0 - r, 0.0, 1.0), 2.4) + 0.5 * pow(clamp(1.0 - r * 4.0, 0.0, 1.0), 2.0);
	}
	ALBEDO = COLOR.rgb;
	ALPHA = a * COLOR.a;
}
