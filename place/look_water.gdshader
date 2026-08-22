shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled,
		diffuse_burley, specular_schlick_ggx;

// Look-owned slow swell on Mat_water / Mat_lid. Fully opaque.
// No refraction, no alpha window, no second drop timer.
// Clock still moves the AnimatableBody3D.

uniform vec4 albedo : source_color = vec4(0.022, 0.068, 0.088, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.32;
uniform float swell_amp : hint_range(0.0, 0.06) = 0.02;
uniform float swell_speed : hint_range(0.0, 1.0) = 0.42;
uniform float swell_scale = 0.38;

float swell(vec3 world, float t)
{
	float a = sin(world.x * swell_scale + t)
			* cos(world.z * swell_scale * 0.73 + t * 0.81);
	float b = sin((world.x * 0.61 + world.z * 0.47) * swell_scale
			+ t * 0.55);
	return a * 0.72 + b * 0.28;
}

void vertex()
{
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float up = smoothstep(0.25, 0.85, NORMAL.y);
	VERTEX.y += swell(world, TIME * swell_speed) * swell_amp * up;
}

void fragment()
{
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * swell_speed;
	float s = swell(world, t);
	ALBEDO = albedo.rgb + vec3(-0.003, 0.004, 0.006) * s;
	ROUGHNESS = roughness + s * 0.04;
	METALLIC = 0.0;
	SPECULAR = 0.45;

	vec3 world_n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up = smoothstep(0.35, 0.85, world_n.y);
	float dx = cos(world.x * swell_scale + t) * swell_amp * 6.0;
	float dz = -sin(world.z * swell_scale * 0.73 + t * 0.81)
			* swell_amp * 6.0;
	vec3 wn = normalize(vec3(-dx, 1.0, -dz));
	vec3 vn = normalize((VIEW_MATRIX * vec4(wn, 0.0)).xyz);
	NORMAL = normalize(mix(NORMAL, vn, up));
}
