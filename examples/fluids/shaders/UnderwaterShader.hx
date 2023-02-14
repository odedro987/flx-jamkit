package examples.fluids.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;

class UnderwaterShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

        uniform sampler2D camBuffer;
        uniform vec2 worldPos;
        uniform float time;
		uniform float blendIntensity;
		uniform float index;
		uniform float segmentCount;
				
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			// Normalize world position in respect to camera size
			float camX = (worldPos.x + uv.x * size.x) / 640.0;
			float camY = (worldPos.y + uv.y * size.y) / 480.0;
			float offsetX = (uv.x + index) / segmentCount;
			float timeVariance = sin(time + offsetX * 4.0 + uv.y * 8.0) * 0.002;
			vec2 camUV = vec2(camX + timeVariance, camY);

			gl_FragColor = texture2D(camBuffer, camUV);
		}")
	public function new(x:Float, y:Float, color:FlxColor, blendIntensity = 0.5)
	{
		super();
		this.worldPos.value = [x, y];
		this.time.value = [0.0];
		this.blendIntensity.value = [blendIntensity];
		setIndex(0, 1);
	}

	public function setIndex(index:Int, total:Int)
	{
		this.index.value = [index];
		this.segmentCount.value = [total];
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
