#pragma header

uniform float redMultiplier;
uniform float greenMultiplier;
uniform float blueMultiplier;
uniform float alphaMultiplier;
uniform float redOffset;
uniform float greenOffset;
uniform float blueOffset;
uniform float alphaOffset;
void main() {
    gl_FragColor = (flixel_texture2D(bitmap, openfl_TextureCoordv) * vec4(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier)) + vec4(redOffset / 255.0, greenOffset / 255.0, blueOffset / 255.0, alphaOffset / 255.0);
}