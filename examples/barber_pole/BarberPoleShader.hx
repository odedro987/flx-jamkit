package examples.barber_pole;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class BarberPoleShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

		uniform float progress;
		uniform float time;
        uniform vec3 col1;
        uniform vec3 col2;
        uniform vec3 col3;
		
		uniform float speed;
		uniform float colorCount;
		uniform float stripeCount;
		uniform float thickness;
		uniform float incline;

		uniform bool autoScale;
		uniform vec2 textureSize;
		uniform float quality;

        float map(float value, float in_min, float in_max, float out_min, float out_max) {
            return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
        }

        float mapUV(float value, float out_min, float out_max) {
            return map(value, 0.0, 1.0, out_min, out_max);
        }
		
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 size;

			// set size
			if (autoScale == true) {
				size = openfl_TextureSize;
			}else{
				size = textureSize * quality;
				uv.x = floor(uv.x * size.x) / size.x;
				uv.y = floor(uv.y * size.y) / size.y;
			}

			// add waves at top
			// discard everything that is outisde current progress
			if (uv.y < 1.0 - progress + cos(uv.x * 3.0 + time * 6.0) / 40.0 + 0.05) {
				gl_FragColor = vec4(vec3(0.3), 1.0);
				if (uv.y < 1.0 - progress + sin(uv.x * 3.0 + time * 6.0) / 40.0) {
					discard;
				}
				return;
			}

			// base color is white
            gl_FragColor = vec4(1.0);
            
            float baseThreshold = 2.0;
            float threshold = baseThreshold + thickness;
			// calculate dMod to get right stripe count in any size
            float dMod = (stripeCount * threshold) / incline;

			// stretch stripes in a tan func
			float tanBound = 3.14 / 2.8;
            float mappedX = mapUV(uv.x, -tanBound, tanBound);
			float d = (tan(mappedX) + uv.y * incline) + (time * speed);

			float colorThreshold = threshold * colorCount;
			vec3 colors[3];
			colors[0] = col1;
			colors[1] = col2;
			colors[2] = col3;

			// paint stripes
			for(float i = 0.0; i < 3.0; i++){
				if (colorCount < (i + 1.0)) continue;
				
				if (mod(d * dMod + (threshold * i), colorThreshold) > colorThreshold - thickness)
				{
					gl_FragColor = vec4(colors[int(i)], 1.0);
				}
			}

            // darken
            for(float i = 3.0; i > 0.0; i--) {
                if (uv.x > 1.0 - 0.1 * i){
                    gl_FragColor.rgb -= 0.1 + 0.05 * i;
                }
            }

			// lighten
            for(float i = 3.0; i > 0.0; i--) {
                if (uv.x < 0.0 + 0.1 * i){
                    gl_FragColor.rgb += 0.1 + 0.05 * i;
                }
            }
		}")
	public function new(col1:FlxColor, ?col2:FlxColor, ?col3:FlxColor)
	{
		super();
		this.time.value = [0];
		this.progress.value = [0];
		this.col1.value = [col1.redFloat, col1.greenFloat, col1.blueFloat];
		this.col2.value = [col2.redFloat, col2.greenFloat, col2.blueFloat];
		this.col3.value = [col3.redFloat, col3.greenFloat, col3.blueFloat];
		this.colorCount.value = [col3 != null ? 3 : col2 != null ? 2 : 1];
		this.incline.value = [8];
		this.thickness.value = [4];
		this.stripeCount.value = [6];
		this.speed.value = [3];
		this.autoScale.value = [true];
	}

	public function setSize(width:Float, height:Float)
	{
		this.autoScale.value = [false];
		this.textureSize.value = [width, height];
		return this;
	}

	public function setQuality(quality:Float)
	{
		if (this.autoScale.value[0] == false)
		{
			this.quality.value = [quality];
		}
		return this;
	}

	public function setThickness(thickness:Float)
	{
		this.thickness.value = [thickness];
		return this;
	}

	public function setSpeed(speed:Float)
	{
		this.speed.value = [speed];
		return this;
	}

	public function setStripeCount(stripeCount:Float)
	{
		this.stripeCount.value = [stripeCount];
		return this;
	}

	public function updateProgress(progress:Float)
	{
		this.progress.value[0] = progress;
		return this;
	}

	public function updateTime(elapsed:Float)
	{
		this.time.value[0] += elapsed;
		return this;
	}
}
