package jamkit.shaders;

import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;

class FollowScrollShader extends FlxShader
{
	private var _parallax:Float;

	@:glFragmentSource("
		#pragma header

        uniform vec2 scrollPos;
		uniform float parallax;
		
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 textureSize = openfl_TextureSize;

			// Normalize scroll
			vec2 normalScroll = scrollPos * parallax;
			normalScroll.x = mod(normalScroll.x, textureSize.x) / textureSize.x;
			normalScroll.y = mod(normalScroll.y, textureSize.y) / textureSize.y;

            vec2 newUV = uv + normalScroll;

			// Wrap newUV
            if (newUV.x > 1.0){
                newUV.x -= 1.0;
            }else if (newUV.x < 0.0){
                newUV.x += 1.0;
            }
           
            if (newUV.y > 1.0){
                newUV.y -= 1.0;
            }else if (newUV.y < 0.0){
                newUV.y += 1.0;
            }
            
			gl_FragColor = texture2D(bitmap, newUV);
		}")
	public function new(parallax:Float)
	{
		super();
		this.parallax.value = [parallax];
	}

	public function updateFollowPosition(pos:FlxPoint)
	{
		this.scrollPos.value = [pos.x, pos.y];
	}
}
