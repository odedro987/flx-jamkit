package jamkit.shaders;

import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;

typedef CRTOptions =
{
	var ?showHorizontalLines:Bool;
	var ?showVerticalLines:Bool;
	var ?showVignette:Bool;
	var ?showCurvature:Bool;
	var ?curvature:FlxPoint;
	var ?scanLineOpacity:Float;
	var ?vignetteOpacity:Float;
	var ?vignetteRoundness:Float;
	var ?brightness:Float;
}

class CRTShader extends FlxShader
{
	private var _defaultOptions:CRTOptions = {
		showHorizontalLines: true,
		showVerticalLines: true,
		showVignette: true,
		showCurvature: true,
		curvature: new FlxPoint(3, 3),
		vignetteOpacity: 1.0,
		scanLineOpacity: 1.0,
		vignetteRoundness: 8.0,
		brightness: 1.2
	}

	@:glFragmentSource('
		#pragma header
		
		// Constants
		const float PI = 3.14;
        
		// Flags
		uniform bool showHorizontalLines;
		uniform bool showVerticalLines;
		uniform bool showVignette;
		uniform bool showCurvature;

		// Variables
		uniform vec2 curvature;
		uniform float scanLineOpacity;
		uniform float vignetteOpacity;
		uniform float vignetteRoundness;
		uniform float brightness;


		vec2 curveUV(vec2 uv) {
			uv = uv * 2.0 - 1.0;
			vec2 offset = abs(uv.yx) / vec2(curvature.x, curvature.y);
			uv = uv + uv * offset * offset;
			uv = uv * 0.5 + 0.5;

			return uv;
		}

		vec4 scanLineIntensity(float uv, float resolution, float opacity)
		{
			float intensity = sin(uv * resolution * PI * 2.0);
			intensity = ((0.5 * intensity) + 0.5) * 0.9 + 0.1;
			return vec4(vec3(pow(intensity, opacity)), 1.0);
		}

		vec4 vignetteIntensity(vec2 uv, vec2 resolution, float opacity, float roundness)
		{
			float intensity = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
			return vec4(vec3(clamp(pow((resolution.x / roundness) * intensity, opacity), 0.0, 1.0)), 1.0);
		}

		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			vec2 textureSize = openfl_TextureSize;
            gl_FragColor = texture2D(bitmap, uv);
			
			if(showCurvature) {
				uv = curveUV(uv);
				
				if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0){
					gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
				}
			}
			
			if(showVignette) {
				gl_FragColor *= vignetteIntensity(uv, textureSize, vignetteOpacity, vignetteRoundness);
			}
			
			if(showVerticalLines) {
				gl_FragColor *= scanLineIntensity(uv.x, textureSize.y, scanLineOpacity);
            }
			
			if(showHorizontalLines) {
				gl_FragColor *= scanLineIntensity(uv.y, textureSize.x, scanLineOpacity);
            }

			if(showHorizontalLines || showVerticalLines) {
				gl_FragColor *= vec4(vec3(brightness), 1.0);
			}
		}')
	public function new(?opts:CRTOptions)
	{
		super();
		if (opts == null)
			opts = _defaultOptions;
		this.showHorizontalLines.value = [opts.showHorizontalLines != null ? opts.showHorizontalLines : true];
		this.showVerticalLines.value = [opts.showVerticalLines != null ? opts.showVerticalLines : true];
		this.showVignette.value = [opts.showVignette != null ? opts.showVignette : true];
		this.showCurvature.value = [opts.showCurvature != null ? opts.showCurvature : true];
		this.curvature.value = opts.curvature != null ? [opts.curvature.x, opts.curvature.y] : [3.0, 3.0];
		this.scanLineOpacity.value = [opts.scanLineOpacity != null ? opts.scanLineOpacity : 1.0];
		this.vignetteOpacity.value = [opts.vignetteOpacity != null ? opts.vignetteOpacity : 1.0];
		this.vignetteRoundness.value = [opts.vignetteRoundness != null ? opts.vignetteRoundness : 4.0];
		this.brightness.value = [opts.brightness != null ? opts.brightness : 1.2];
	}
}
