package jamkit.components.dialog;

import addons.FlxTypeText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.io.Float32Array;
import jamkit.components.dialog.Types;
import openfl.Assets;

class DialogManager extends FlxTypedGroup<FlxSprite>
{
	public var typeText:FlxTypeText;

	private var _x:Float;
	private var _y:Float;
	private var _actorSprite:FlxSprite;
	private var _dialogRect:FlxSprite;
	private var _textCompleted:Bool;
	private var _isConsumingLines:Bool;
	private var _isConsumingScript:Bool;
	private var _hasActor:Bool;
	private var _currentScript:DialogScript;
	private var _eventsMap:DialogEventsMap;
	private var _lineQueue:Array<String>;
	private var _currentDialogChunk:Int;
	private var _onComplete:Void->Void;

	public function new(x:Float, y:Float, textOffsetX:Float, textOffsetY:Float, textWidth:Int, fontSize:Int, ?onComplete:Void->Void)
	{
		super();
		_x = x;
		_y = y;
		visible = false;
		_textCompleted = false;
		_isConsumingLines = false;
		_isConsumingScript = false;
		_hasActor = false;
		_lineQueue = new Array<String>();
		_onComplete = onComplete;

		_dialogRect = new FlxSprite(_x, _y);
		_dialogRect.visible = false;
		add(_dialogRect);

		_actorSprite = new FlxSprite(_x, _y);
		_actorSprite.visible = false;
		_hasActor = false;
		add(_actorSprite);

		typeText = new FlxTypeText(_x + textOffsetX, _y + textOffsetY, textWidth, "", fontSize, true);
		typeText.scrollFactor.set(0, 0);
		add(typeText);
	}

	public function setDialogBackground(backgroundGraphic:FlxGraphicAsset):DialogManager
	{
		_dialogRect.loadGraphic(backgroundGraphic);
		_dialogRect.visible = true;
		_dialogRect.scrollFactor.set(0, 0);
		return this;
	}

	public function setDialogActor(actorSpriteOffsetX:Float = 0, actorSpriteOffsetY:Float = 0, scale:Float = 1):DialogManager
	{
		_hasActor = true;
		_actorSprite.scrollFactor.set(0, 0);
		_actorSprite.scale.set(scale, scale);
		_actorSprite.visible = false;

		return this;
	}

	public function launch(actor:DialogActor, text:String)
	{
		FlxG.keys.reset();

		typeText.prefix = actor.name + ": ";
		visible = true;

		writeLine(text);

		if (_hasActor)
		{
			if (actor.graphic != null)
			{
				_actorSprite.loadGraphic(FlxG.bitmap.get(actor.graphic), true, _actorSprite.frameWidth, _actorSprite.frameHeight, false, actor.graphic);
			}
			_actorSprite.visible = actor.graphic != null;
		}

		if (_onComplete != null)
		{
			_onComplete();
		}
	}

	function launchMultiple(actor:DialogActor, textLines:Array<String>)
	{
		typeText.prefix = actor.name + ": ";
		visible = true;

		if (_hasActor)
		{
			if (actor.graphic != null)
			{
				_actorSprite.loadGraphic(FlxG.bitmap.get(actor.graphic), true, _actorSprite.frameWidth, _actorSprite.frameHeight, true);
			}
			_actorSprite.visible = actor.graphic != null;
		}

		textLines.reverse();
		_lineQueue = _lineQueue.concat(textLines);
		_isConsumingLines = true;
		writeLine(_lineQueue.pop());
	}

	function writeLine(text:String)
	{
		typeText.resetText(text);
		_textCompleted = false;
		typeText.start(0.02, false, false, null, completeText);
	}

	private function completeText()
	{
		_textCompleted = true;
	}

	public function playScript(scriptPath:String, ?eventsMap:DialogEventsMap)
	{
		_currentScript = Json.parse(Assets.getText(scriptPath));
		_currentDialogChunk = 0;
		_isConsumingScript = true;
		_eventsMap = eventsMap != null ? eventsMap : [];

		handleChunk(_currentScript.dialog[0]);
	}

	function handleChunk(chunk:DialogChunk)
	{
		if (chunk.event != null && _eventsMap.exists(chunk.event))
		{
			_eventsMap[chunk.event]();
		}
		launchMultiple(_currentScript.actors[chunk.actorIndex], chunk.lines);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE && !_textCompleted)
		{
			typeText.skip();
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.SPACE && _textCompleted)
		{
			_textCompleted = false;
			if (_isConsumingLines && _lineQueue.length > 0)
			{
				writeLine(_lineQueue.pop());
			} else if (_isConsumingLines && _lineQueue.length <= 0)
			{
				_isConsumingLines = false;
				_currentDialogChunk++;
				if (_isConsumingScript && _currentDialogChunk < _currentScript.dialog.length)
				{
					var nextChunk = _currentScript.dialog[_currentDialogChunk];
					handleChunk(nextChunk);
				} else
				{
					_isConsumingScript = false;
					visible = false;
				}
			} else
			{
				// Dialog fully completed
				visible = false;
				if (_onComplete != null)
				{
					_onComplete();
				}
			}
		}
	}
}
