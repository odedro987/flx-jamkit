package jamkit.components;

import flixel.FlxSprite;
import flixel.ui.FlxButton.FlxTypedButton;

class SpriteButton extends FlxTypedButton<FlxSprite>
{
	var onClick:Void->Void = null;

	public function new(x:Float, y:Float, graphic:String, width:Int, height:Int, ?onClick:Void->Void)
	{
		super(x, y, onClick);
		loadGraphic(graphic, true, width, height);
		graphicLoaded();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
