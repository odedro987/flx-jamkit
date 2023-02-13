package scenes.bar_scene;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class BarberPole extends FlxTypedGroup<FlxSprite>
{
	var bar:FlxSprite;
	var container:FlxSprite;

	// var barShader:TextureBarShader;
	var barShader:ProcBarShader;

	var progress:Float;

	public function new(x:Float, y:Float)
	{
		super(2);

		bar = new FlxSprite(x + 4, y + 18);
		bar.makeGraphic(24, 112);
		// barShader = new TextureBarShader(AssetPaths.bar_seg__png);
		barShader = new ProcBarShader(0xffff0040, 0xff0055ff, 0xffffe600);
		bar.shader = barShader;
		add(bar);

		container = new FlxSprite(x, y, AssetPaths.barber_pole__png);
		add(container);

		progress = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.UP)
		{
			progress += elapsed / 3;
		} else if (FlxG.keys.pressed.DOWN)
		{
			progress -= elapsed / 3;
		}

		barShader.updateProgress(progress);
		barShader.updateTime(elapsed);
	}
}

private class TextureBarShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

		uniform sampler2D segTex;
		uniform float progress;
		uniform float time;
		
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			if (uv.y < 1.0 - progress + sin(uv.x * 3.0 + time * 2.0) / 30.0) {
				discard;
			}

			vec2 newUV = uv;
			newUV.y = mod(uv.y * 2.0 + time, 1.0);
	
			gl_FragColor = texture2D(segTex, newUV);
		}")
	public function new(graphic:FlxGraphicAsset)
	{
		super();
		this.time.value = [0];
		this.progress.value = [0];
		this.segTex.input = new FlxSprite(0, 0, graphic)
			.graphic.bitmap;
	}

	public function updateProgress(progress:Float)
	{
		this.progress.value[0] = progress;
	}

	public function updateTime(elapsed:Float)
	{
		this.time.value[0] += elapsed;
	}
}

private class ProcBarShader extends FlxShader
{
	@:glFragmentSource("
		#pragma header

		uniform float progress;
		uniform float time;
        uniform vec3 col1;
        uniform vec3 col2;
        uniform vec3 col3;

        float map(float value, float in_min, float in_max, float out_min, float out_max) {
            return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
        }

        float mapUV(float value, float out_min, float out_max) {
            return map(value, 0.0, 1.0, out_min, out_max);
        }
		
		void main(void) {
			#pragma body

            vec2 uv = openfl_TextureCoordv;
			vec2 size = openfl_TextureSize;

			if (uv.y < 1.0 - progress + sin(uv.x * 3.0 + time * 6.0) / 30.0) {
				discard;
			}

            gl_FragColor = vec4(1.0);
            
            float baseThreshold = 2.0;
            float stripeCount = 6.0;
            float angle = 8.0;
            float thickness = 4.0;
            float speed = 4.0;

            float threshold = baseThreshold + thickness;
            float dMod = (stripeCount * threshold) / angle;

            float mappedX = mapUV(uv.x, -3.14 / 3.0, 3.14 / 3.0);

			float d = (tan(mappedX) + uv.y * angle) + (time * speed);
			// float d = uv.x + uv.y * angle;

            if (mod(d * dMod, threshold) > 2.0)
            {
                gl_FragColor = vec4(col1, 1.0);
            }

            if (mod(d * dMod, threshold * 2.0) > 2.0 + threshold)
            {
                gl_FragColor = vec4(col2, 1.0);
            }
            
            // if (mod(d * dMod, threshold * 3.0) > 2.0 + threshold * 2.0)
            // {
            //     gl_FragColor = vec4(col3, 1.0);
            // }

            // darken
            for(float i = 3.0; i > 0.0; i--) {
                if (uv.x > 1.0 - 0.1 * i){
                    gl_FragColor.rgb -= 0.1 + 0.05 * i;
                }
            }
		}")
	public function new(col1:FlxColor, col2:FlxColor, col3:FlxColor)
	{
		super();
		this.time.value = [0];
		this.progress.value = [0];
		this.col1.value = [col1.redFloat, col1.greenFloat, col1.blueFloat];
		this.col2.value = [col2.redFloat, col2.greenFloat, col2.blueFloat];
		this.col3.value = [col3.redFloat, col3.greenFloat, col3.blueFloat];
	}

	public function updateProgress(progress:Float)
	{
		this.progress.value[0] = progress;
	}

	public function updateTime(elapsed:Float)
	{
		this.time.value[0] += elapsed;
	}
}
