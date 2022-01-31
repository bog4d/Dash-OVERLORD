package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class HUD extends FlxSpriteGroup
{
	public var _vignette:FlxSprite;

	public function new()
	{
		super();
		_vignette = new FlxSprite().loadGraphic('assets/images/vignette.png');
		_vignette.color = 0x000000;
		// Layering
		add(_vignette);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		_vignette.color = FlxColor.interpolate(_vignette.color, 0x000000, 2 * elapsed);
	}
}
