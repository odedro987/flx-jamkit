package jamkit.components.dialog;

typedef DialogActor =
{
	var name:String;
	var graphic:String;
}

typedef DialogChunk =
{
	var actorIndex:Int;
	var ?event:String;
	var lines:Array<String>;
}

typedef DialogScript =
{
	var actors:Array<DialogActor>;
	var dialog:Array<DialogChunk>;
}

typedef DialogEventsMap = Map<String, Void->Void>;
