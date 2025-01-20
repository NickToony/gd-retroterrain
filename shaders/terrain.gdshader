shader_type spatial;

uniform sampler2D grassTexture: source_color;
uniform sampler2D rockTexture: source_color;
uniform sampler2D sandTexture: source_color;

uniform float lineThickness = 0.02;
uniform float lineVisibility = 0.3;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float lines = 1.;
	float upperLineThreshold = (1. - lineThickness);
	if (UV.x < lineThickness || UV.x > upperLineThreshold || UV.y < lineThickness || UV.y > upperLineThreshold) {
		lines = 1. - lineVisibility;
	}

	vec3 layer0 = texture(grassTexture, UV).xyz * (1.0 - COLOR.r - COLOR.g - COLOR.b);
	vec3 layer1 = texture(rockTexture, UV).xyz * COLOR.r;
	vec3 layer2 = texture(sandTexture, UV).xyz * COLOR.g;
	ALBEDO = (layer0 + layer1 + layer2) * lines;
}
