package jamkit.components.emitter;

@:enum
abstract EmitAngle(Float) from Float to Float
{
	var RIGHT = 0.0;
	var DOWN = 90.0;
	var LEFT = 180.0;
	var UP = 270.0;
}

enum EmitterType
{
	STRAIGHT;
}

enum EmitterPath
{
	POLYGON;
	LINE;
	TRIANGLE;
	RECTANGLE;
	SQUARE;
	ELLIPSE;
	CIRCLE;
}
