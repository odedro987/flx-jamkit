package scenes.water_scene;

import examples.fluids.WaterBody;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import jamkit.shaders.SwayingVertexShader;

class WaterShaderScene extends FlxState
{
	var water:WaterBody;
	var backgroundCam:FlxCamera;
	var waterCam:FlxCamera;
	var screenSprite:FlxSprite;

	var t1Shader = new SwayingVertexShader(FlxG.random.float(-0.8, 0.6), [6.5, 13, 2.5], [1, 2, 0.6], [1.5, 2, 0.5], [1, 2, 0.6]);
	var t2Shader = new SwayingVertexShader(FlxG.random.float(-0.8, 0.6), [6.5, 13, 2.5], [1, 2, 0.6]);

	override public function create()
	{
		super.create();

		backgroundCam = new FlxCamera();
		backgroundCam.bgColor = 0xff0e9cb6;
		FlxG.cameras.add(backgroundCam);
		screenSprite = new FlxSprite();
		screenSprite.makeGraphic(640, 480, FlxColor.WHITE, true);

		waterCam = new FlxCamera();
		waterCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(waterCam);

		var foregroundCam = new FlxCamera();
		foregroundCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(foregroundCam);

		var bg = add(new FlxSprite(0, 0, AssetPaths.water_background__png));
		bg.camera = backgroundCam;
		var r1 = add(new FlxSprite(4 * 16, 5 * 16 + 6, AssetPaths.water_rock__png));
		r1.camera = backgroundCam;
		var r2 = add(new FlxSprite(8 * 16, 8 * 16 + 4, AssetPaths.water_rock__png));
		r2.camera = backgroundCam;
		var v = add(new FlxSprite(5 * 16, 8 * 16, AssetPaths.water_veggies__png));
		v.camera = backgroundCam;

		// water = new WaterBodySegment(0, 6 * 16 + 4, 16 * 16, 4 * 16 - 4, 0xff3870ff);
		water = new WaterBody(0, 6 * 16 + 4, 16 * 16, 4 * 16 - 4, 0xff3870ff, 1);
		water.camera = waterCam;
		add(water);

		var fg = add(new FlxSprite(0, 0, AssetPaths.water_forground__png));
		fg.camera = foregroundCam;
		var t1 = add(new FlxSprite(1 * 16, 2 * 16, AssetPaths.water_tree__png));
		cast(t1, FlxSprite)
			.shader = t1Shader;
		t1.camera = foregroundCam;
		var t2 = add(new FlxSprite(12 * 16, 3 * 16, AssetPaths.water_tree__png));
		cast(t2, FlxSprite)
			.shader = t2Shader;
		t2.camera = foregroundCam;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		t1Shader.time.value[0] += elapsed;
		t2Shader.time.value[0] += elapsed;

		screenSprite.pixels.draw(backgroundCam.canvas);
		water.updateCamBuffer(screenSprite);
	}
}
