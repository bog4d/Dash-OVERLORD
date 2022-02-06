package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class JumpPad extends FlxSprite
{
	public var launchForce:Int;
	public var cooldown:Bool;

	public function new()
	{
		super();
		loadGraphic('assets/images/jumpPad.png'); // maybe add some animations (i killed a spider while writing this)
		updateHitbox();
		immovable = true;
		cooldown = false;
	}
}
