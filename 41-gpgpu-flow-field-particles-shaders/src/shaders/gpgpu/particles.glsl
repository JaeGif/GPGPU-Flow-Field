uniform float uTime;
uniform float uDeltaTime;
uniform sampler2D uBase;
uniform float uFlowFieldInfluence;
uniform float uFlowFieldStrength;
uniform float uFlowFieldFrequency;

#include ../includes/simplexNoise4d.glsl

void main() {
    float time = uTime * 0.2;

    // already have access to uParticles
    // rgba == xyzw
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 particle = texture(uParticles, uv);
    vec4 base = texture(uBase, uv);

    // dead
    if (particle.a >= 1.0) {
        particle.a = mod(particle.a, 1.0);
        particle.xyz = base.xyz;

    } else {
        // strength
        float influence = (uFlowFieldInfluence - 0.5) * (-2.0);
        float strength = smoothstep(influence, 1.0, simplexNoise4d(vec4(base.xyz, time + 1.0)));


        // flow field
        vec3 flowField = vec3(
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 0.0, time)), 
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 1.0, time)), 
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 2.0, time))
        );

        flowField = normalize(flowField);
        particle.xyz += flowField * uDeltaTime * strength * uFlowFieldStrength;
        particle.w += uDeltaTime * 0.3;
    }


    

    gl_FragColor = particle;
}