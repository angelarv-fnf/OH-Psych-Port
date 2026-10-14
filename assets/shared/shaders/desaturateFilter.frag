//https://www.shadertoy.com/view/lsdXDH
#pragma header
//vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
uniform bool enabled;

// Generic algorithm to desaturate images used in most game engines
vec4 generic_desaturate(vec3 color, float factor)
{
	vec3 lum = vec3(0.299, 0.587, 0.114);
	vec3 gray = vec3(dot(lum, color));
	return vec4(mix(color, gray, factor), 1.0);
}

void mainImage()
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    if (!enabled) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
        return;
    }
    
	fragColor = generic_desaturate(texture(iChannel0, uv).rgb, 1.0);

    fragColor = texture(iChannel0, uv);
}