package jamkit.shaders;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.ShaderParameter;

class WavyGrassShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header
		
		void main(void) {
			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
		}")
	@:glVertexSource("
		#pragma header
		
		uniform float time;
		uniform float delay;
		uniform int xCutoff;
		uniform int yCutoff;
		uniform float xAmplitudes[16];
		uniform float yAmplitudes[16];
		uniform float xFrequencies[16];
		uniform float yFrequencies[16];

		float combineSines(float amplitudes[16], float frequencies[16], int cutoff){
			float y = 0.;
			for (int i = 0; i < 16; i++){
				if(i == cutoff)
					break;
				y += amplitudes[i] * sin((time + delay) * frequencies[i]);
			}
			return y;
		}
		
		void main(void) {
			#pragma body

			vec2 uv = openfl_Position.xy;
            
			// if vertex is one of the top 2 vertices
			if(openfl_TextureCoord.y == 0.){
				uv.x += combineSines(xAmplitudes, xFrequencies, xCutoff);
				uv.y += combineSines(yAmplitudes, yFrequencies, yCutoff);
			}
			
			gl_Position = openfl_Matrix * vec4(uv, openfl_Position.zw);
		}")
	public function new(delay:Float, xAmplitudes:Array<Float>, xFrequencies:Array<Float>, ?yAmplitudes:Array<Float>, ?yFrequencies:Array<Float>)
	{
		super();
		this.alpha = new ShaderParameter();
		this.time.value = [0.0];
		this.delay.value = [delay];
		this.xCutoff.value = [xAmplitudes.length];
		this.yCutoff.value = [yAmplitudes != null ? xAmplitudes.length : 0];
		this.xAmplitudes.value = padArray(xAmplitudes);
		this.xFrequencies.value = padArray(xFrequencies);
		this.yAmplitudes.value = yAmplitudes != null ? padArray(yAmplitudes) : [for (_ in 0...16) 0.0];
		this.yFrequencies.value = yFrequencies != null ? padArray(yFrequencies) : [for (_ in 0...16) 0.0];
	}

	private function padArray(array:Array<Float>)
	{
		for (_ in 0...(16 - array.length)) array.push(0.0);

		return array;
	}
}
