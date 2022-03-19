#version 430

#include "../fragments/fs_common_inputs.glsl"

// We output a single color to the color buffer
layout(location = 8) in vec3 inFragPos;
layout(location = 0) out vec4 frag_color;

////////////////////////////////////////////////////////////////
/////////////// Instance Level Uniforms ////////////////////////
////////////////////////////////////////////////////////////////

// Represents a collection of attributes that would define a material
// For instance, you can think of this like material settings in 
// Unity
struct Material {
	sampler2D Diffuse;
	float     Shininess;
};
// Create a uniform for the material
uniform Material u_Material;

////////////////////////////////////////////////////////////////
///////////// Application Level Uniforms ///////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/multiple_point_lights.glsl"

////////////////////////////////////////////////////////////////
/////////////// Frame Level Uniforms ///////////////////////////
////////////////////////////////////////////////////////////////

#include "../fragments/frame_uniforms.glsl"
#include "../fragments/color_correction.glsl"

// https://learnopengl.com/Advanced-Lighting/Advanced-Lighting
void main() {
	// Normalize our input normal
	vec3 normal = normalize(inNormal);
	vec3 toEye = normalize(u_CamPos.xyz - inFragPos);
	// Use the lighting calculation that we included from our partial file
	vec3 lightAccumulation = CalcAllLightContribution(inFragPos, normal, u_CamPos.xyz, u_Material.Shininess);

	// Get the albedo from the diffuse / albedo map
	vec4 textureColor = texture(u_Material.Diffuse, inUV);

	vec3 specular = vec3(0.0);
	float specStr = 0.5;
	vec3 viewDir = normalize(inViewPos - inFragPos);
	vec3 reflectDir = reflect(-toEye, normal);
	float specPow = pow(max(dot(viewDir, reflectDir), 0.0), 32);
	//Specular
	//if (IsFlagSet(FLAG_ENABLE_SPECULAR))
	//{
		specular = specStr * specPow * lightAccumulation;
	//}
	
	vec3 ambient = vec3(0);
	float ambStr = 0.1;
	//Ambient
	//if (IsFlagSet(FLAG_ENABLE_AMBIENT))
	//{
		ambient = ambStr * lightAccumulation;
	//}

	vec3 diffuse = vec3(0.0);
	float dif = max(dot(normal, viewDir),0.0);;
	//Diffuse
	//if (IsFlagSet(FLAG_ENABLE_DIFFUSE))
	//{
		diffuse = dif * lightAccumulation;
	//}

	// combine for the final result
	vec3 result = (specular + diffuse + ambient) * vec3(1);
	//vec3 result = lightAccumulation  * inColor * textureColor.rgb;

	frag_color = vec4(result, 1.0);
}