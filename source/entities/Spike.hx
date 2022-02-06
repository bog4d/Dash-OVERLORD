package;

import flixel.FlxSprite;

class Spike extends FlxSprite
{
	public function new()
	{
		super();
		loadGraphic('assets/images/spike.png');
		updateHitbox();
		immovable = true;
	}
}
