package jamkit.components.fluids;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import jamkit.shaders.WaterSpringShader;

class WaterSpringSegment extends FlxSprite
{
	var waterShader:WaterSpringShader;

	public function new(x:Float, y:Float, width:Int, height:Int, color:FlxColor, snapToGrid:Bool = true, blendIntensity:Float = 0.5)
	{
		super(x, y);
		makeGraphic(width, height, color);
		this.waterShader = new WaterSpringShader(x, y, color, snapToGrid, blendIntensity);
		this.shader = this.waterShader;
	}

	public function setIndex(index:Int, segmentCount:Int)
	{
		this.waterShader.setIndex(index, segmentCount);
	}

	public function updateOffsetY(isLeft:Bool, offset:Float)
	{
		this.waterShader.updateOffsetY(isLeft, offset);
	}

	public function updateCamBuffer(buffer:FlxSprite)
	{
		this.waterShader.updateCamBuffer(buffer.graphic.bitmap);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		this.waterShader.updateTime(elapsed);
	}
}
