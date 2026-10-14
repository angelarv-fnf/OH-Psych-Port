#pragma header

uniform vec2 offset;
uniform float ratio;

void main() {
    vec2 pos = getCamPos(openfl_TextureCoordv);


    pos -= vec2(0.5, 0.5 * ratio);

    vec3 v1 = vec3(1, 1, 6);
    vec3 v2 = vec3(0.5, 0.5, 2.5);

    vec3 dpos = vec3(mix(v1.x, v2.x, pos.x), mix(v1.y, v2.y, pos.x), mix(v1.z, v2.z, pos.x));

    float mul = ((1/(dpos.z/(dpos.z-(-2))))-1);
    vec2 screenpos = vec2(
        (dpos.x * mul) * 16.0/9.0,
        (dpos.y * mul) * 9.0/16.0
    );
    screenpos /= vec2(16.0/9.0, 9.0/16.0);
    pos += vec2(0.5, 0);

    gl_FragColor = textureCam(bitmap, mix(mod(pos + offset, 1), mod((pos / screenpos) + offset, 1), ratio));
}