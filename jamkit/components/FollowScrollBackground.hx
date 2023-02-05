package jamkit.components;

import flixel.FlxG;
import flixel.FlxSprite;
import jamkit.shaders.FollowScrollShader;

class FollowScrollBackground extends FlxSprite
{
	var _scrollShader:FollowScrollShader;

	public function new(graphic:flixel.system.FlxAssets.FlxGraphicAsset, parallax:Float = 1)
	{
		super(0, 0, graphic);
		this._scrollShader = new FollowScrollShader(parallax);
		scrollFactor.set(0, 0);
		shader = _scrollShader;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_scrollShader.updateFollowPosition(FlxG.camera.scroll);
	}
}
