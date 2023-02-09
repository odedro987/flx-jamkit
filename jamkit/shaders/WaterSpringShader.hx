package jamkit.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;

class WaterSpringShader extends FlxShader
{
	var _snapToGrid:Bool;

	@:glFragmentSource("
		#pragma header

        uniform sampler2D camBuffer;
		uniform vec4 baseColor;
        uniform vec2 worldPos;
        uniform float time;
		uniform float blendIntensity;
		uniform float index;
		uniform float segmentCount;
		
		void main(void) {
			

            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			// Add light outline to the top
			if (floor(uv.y * size.y) == 0.0) {
				vec3 diff = vec3(1.0) - baseColor.rgb;
				gl_FragColor = vec4(baseColor.rgb + diff * 0.7, 1.0);
				return;
			}else {
				// Normalize world position in respect to camera size
				float camX = (worldPos.x + uv.x * size.x) / 640.0;
				float camY = (worldPos.y + uv.y * size.y) / 480.0;

				float offsetX = (uv.x + index) / segmentCount;

				float timeVariance = sin(time + offsetX * 4.0 + uv.y * 10.0) * 0.002;
				vec2 camUV = vec2(camX + timeVariance, camY);
	
				gl_FragColor = baseColor * (1.0 - blendIntensity) + texture2D(camBuffer, camUV) * blendIntensity;
			}

		}")
	@:glVertexSource("
		#pragma header
		
		uniform vec2 offsetsY;
		
		void main(void) {
			#pragma body
			vec2 uv = openfl_Position.xy;
            
			// if vertex is one of the top 2 vertices
			if(openfl_TextureCoord.y == 0.0){
				if(openfl_TextureCoord.x == 0.0) {
					uv.y = offsetsY.x;
				}else {
					uv.y = offsetsY.y;
				}
			}
			
			gl_Position = openfl_Matrix * vec4(uv, openfl_Position.zw);
		}")
	public function new(x:Float, y:Float, color:FlxColor, snapToGrid:Bool = true, blendIntensity = 0.5)
	{
		super();
		this.alpha = new ShaderParameter();
		this._snapToGrid = snapToGrid;
		this.worldPos.value = [x, y];
		this.baseColor.value = [color.redFloat, color.greenFloat, color.blueFloat, 1.0];
		this.time.value = [0.0];
		this.blendIntensity.value = [blendIntensity];
		this.offsetsY.value = [0.0, 0.0];
		setIndex(0, 1);
	}

	public function setIndex(index:Int, total:Int)
	{
		this.index.value = [index];
		this.segmentCount.value = [total];
	}

	public function updateOffsetY(isLeft:Bool, offset:Float)
	{
		this.offsetsY.value[isLeft ? 0 : 1] = this._snapToGrid ? Math.floor(offset) : offset;
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
