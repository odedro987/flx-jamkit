package jamkit.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;

class WaterShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

        uniform sampler2D camBuffer;
		uniform vec4 baseColor;
        uniform vec2 worldPos;
        uniform float time;
		uniform float blendIntensity;
		
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			// Add light outline to the top
			if (uv.y <= 1.0 / 120.0) {
				vec3 diff = vec3(1.0) - baseColor.rgb;
				gl_FragColor = vec4(baseColor.rgb + diff * 0.7, 1.0);
				return;
			}else {

				// Normalize world position in respect to camera size
				float camX = (worldPos.x + uv.x * size.x) / 640.0;
				float camY = (worldPos.y + uv.y * size.y) / 480.0;
				float timeVariance = sin(time + uv.x * 4.0 + uv.y * 8.0) * 0.002;
				vec2 camUV = vec2(camX + timeVariance, camY);
	
				gl_FragColor = baseColor * (1.0 - blendIntensity) + texture2D(camBuffer, camUV) * blendIntensity;
			}

		}")
	public function new(x:Float, y:Float, color:FlxColor, blendIntensity = 0.5)
	{
		super();
		this.worldPos.value = [x, y];
		this.baseColor.value = [color.redFloat, color.greenFloat, color.blueFloat, 1.0];
		this.time.value = [0.0];
		this.blendIntensity.value = [blendIntensity];
	}

	public function updateCamBuffer(camBuffer:BitmapData)
	{
		this.camBuffer.input = camBuffer;
	}

	public function updateTime(elapsed:Float)
	{
		this.time.value[0] += elapsed;
	}
}
