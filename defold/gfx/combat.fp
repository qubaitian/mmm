#version 140
in mediump vec2 var_texcoord0;
out vec4 out_fragColor;
uniform mediump sampler2D texture_sampler;
uniform fs_uniforms {
    mediump vec4 tint;
    mediump vec4 flash;
};
void main() {
    mediump vec4 color = texture(texture_sampler, var_texcoord0);
    color.rgb = mix(color.rgb, vec3(color.a), flash.x);
    out_fragColor = color * vec4(tint.rgb * tint.a, tint.a);
}
