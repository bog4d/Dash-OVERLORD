package;

import flixel.FlxG;
import flixel.FlxSprite;

class Spike extends FlxSprite
{
	public function new()
	{
		super();

		var flipped:Bool = FlxG.random.bool(50);
		loadGraphic('assets/images/spike.png');
		if (flipped)
			flipX = true;
		else
			flipX = false;

		immovable = true;
	}
}
