package;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

// thank u ninjamuffin99 u r the reason i learned HaxeFlixel :)
class LevelButton extends FlxSpriteGroup
{
	public var daY:Float;

	var daText:FlxText;

	public function new(X, Y, daId:Int)
	{
		super();
		daText = new FlxText(0, 0, FlxG.width, 'Level $daId');
		daText.setPosition(X, Y);
		daText.setFormat('assets/data/fonts/karma.TTF', 64, FlxColor.WHITE, FlxTextAlign.LEFT);
		// antialiasing = true;
		alpha = 0.5;

		switch (daText.text)
		{
			case 'Level 0':
				daText.text = 'TUTORIAL';
		}

		add(daText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		daText.y = FlxMath.lerp(daText.y, 120 + daY * 69, 0.17);
	}
}
