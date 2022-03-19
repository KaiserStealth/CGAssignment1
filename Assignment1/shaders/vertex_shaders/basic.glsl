#version 440

// Include our common vertex shader attributes and uniforms
#include "../fragments/vs_common.glsl"

layout(location = 8) out vec3 outFragPos;

void main() {

	gl_Position = u_ModelViewProjection * vec4(inPosition, 1.0);

	// Lecture 5
	// Pass vertex pos in world space to frag shader
	outViewPos = (u_ModelView * vec4(inPosition, 1.0)).xyz;

	// Normals
	outNormal = (u_View * vec4(mat3(u_NormalMatrix) * inNormal, 0)).xyz;

	outFragPos = vec3(u_Model * vec4(inPosition, 1.0));

    // We use a TBN matrix for tangent space normal mapping
    vec3 T = normalize((u_View * vec4(mat3(u_NormalMatrix) * inTangent, 0)).xyz);
    vec3 B = normalize((u_View * vec4(mat3(u_NormalMatrix) * inBiTangent, 0)).xyz);
    vec3 N = normalize((u_View * vec4(mat3(u_NormalMatrix) * inNormal, 0)).xyz);
    mat3 TBN = mat3(T, B, N);

    // We can pass the TBN matrix to the fragment shader to save computation
    outTBN = TBN;

	// Pass our UV coords to the fragment shader
	outUV = inUV;

	///////////
	outColor = inColor;

}

