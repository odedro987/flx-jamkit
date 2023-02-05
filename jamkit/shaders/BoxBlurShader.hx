package jamkit.shaders;

import flixel.system.FlxAssets.FlxShader;

class BoxBlurShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header

        uniform bool isVertictal;
        uniform float blurSize;
        const float blurPasses = 10.0;

		void main(void) {
            vec2 uv = openfl_TextureCoordv;
			vec2 textureSize = openfl_TextureSize;

            float oneLess = blurPasses - 1.0;
            float ratio = textureSize.y / textureSize.x;
            vec4 col = vec4(0.);
            
            for(float i = 0.0; i < blurPasses; i++){
                vec2 uvi;
                if (isVertictal)
                    uvi = uv + vec2(0, (i / oneLess - 0.5) * blurSize);
                else 
                    uvi = uv + vec2((i / oneLess - 0.5) * blurSize * ratio, 0);
                col += texture2D(bitmap, uvi);
                
            }

            col = col / blurPasses;
            gl_FragColor = col;
		}")
	public function new(blurSize:Float = 0.01)
	{
		super();
		this.isVertictal.value = [true];
		this.blurSize.value = [blurSize];
	}
}
