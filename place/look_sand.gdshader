shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back,
		diffuse_burley, specular_schlick_ggx;

// Look-owned sand/rock grain. World XZ only so CSG box sides do not
// stamp a tiled atlas. Soft, large patches. Not a 256px noise tex.
// Clock still owns the drop. Place still owns the mesh.

uniform vec4 sand_dark : source_color = vec4(0.48, 0.39, 0.28, 1.0);
uniform vec4 sand_light : source_color = vec4(0.70, 0.60, 0.44, 1.0);
uniform float grain_scale = 4.0;
uniform float grain_contrast : hint_range(0.0, 1.0) = 0.22;
uniform float roughness_base : hint_range(0.0, 1.0) = 0.93;
uniform float bump : hint_range(0.0, 0.2) = 0.03;
uniform float seed = 0.0;

float hash(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p)
{
	float v = 0.0;
	float a = 0.5;
	mat2 m = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	for (int i = 0; i < 5; i++)
	{
		v += a * value_noise(p);
		p = m * p * 2.02;
		a *= 0.5;
	}
	return v;
}

void fragment()
{
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 uv = world.xz / max(grain_scale, 0.2) + vec2(seed, seed * 0.37);
	float patch = fbm(uv);
	float fine = fbm(uv * 2.6 + vec2(4.2, 1.1));
	float grain = mix(patch, fine, 0.22);
	grain = mix(0.5, grain, grain_contrast);
	ALBEDO = mix(sand_dark.rgb, sand_light.rgb, grain);
	ROUGHNESS = roughness_base + (grain - 0.5) * 0.06;
	METALLIC = 0.0;
	SPECULAR = 0.15;

	vec3 world_n = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float up = smoothstep(0.4, 0.85, world_n.y);
	float h = fbm(uv);
	float hx = fbm(uv + vec2(0.07, 0.0));
	float hz = fbm(uv + vec2(0.0, 0.07));
	float k = bump * 5.0;
	vec3 wn = normalize(vec3((h - hx) * k, 1.0, (h - hz) * k));
	vec3 vn = normalize((VIEW_MATRIX * vec4(wn, 0.0)).xyz);
	NORMAL = normalize(mix(NORMAL, vn, up));
}
