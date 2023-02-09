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

		uniform vec4 baseColor;
        uniform float time;
		uniform float blendIntensity;
		
		void main(void) {
            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			// Add light outline to the top
			if (floor(uv.y * size.y) == 0.0) {
				vec3 diff = vec3(1.0) - baseColor.rgb;
				gl_FragColor = vec4(baseColor.rgb + diff * 0.7, 1.0);
				return;
			}
			
			gl_FragColor = baseColor * (1.0 - blendIntensity);
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
	public function new(color:FlxColor, snapToGrid:Bool = true, blendIntensity = 0.5)
	{
		super();
		this.alpha = new ShaderParameter();
		this._snapToGrid = snapToGrid;
		this.baseColor.value = [color.redFloat, color.greenFloat, color.blueFloat, 1.0];
		this.blendIntensity.value = [blendIntensity];
		this.offsetsY.value = [0.0, 0.0];
	}

	public function updateOffsetY(isLeft:Bool, offset:Float)
	{
		this.offsetsY.value[isLeft ? 0 : 1] = this._snapToGrid ? Math.floor(offset) : offset;
	}
}
