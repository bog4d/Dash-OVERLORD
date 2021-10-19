package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Popup extends FlxSpriteGroup
{
	var bgLol:FlxSprite;
	var songName:FlxText;

	public function new(title:String)
	{
		super(x, y);
		bgLol = new FlxSprite(-500, 50).makeGraphic(500, 50, FlxColor.BLACK);
		bgLol.alpha = 0.5;

		songName = new FlxText(-500, bgLol.y + 5, FlxG.width, title).setFormat(null, 30, FlxColor.WHITE, FlxTextAlign.LEFT);

		add(bgLol);
		add(songName);

		FlxTween.tween(bgLol, {x: 0}, 1, {
			ease: FlxEase.cubeOut
		});

		FlxTween.tween(songName, {x: 10}, 1, {
			ease: FlxEase.cubeOut
		});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			FlxTween.tween(bgLol, {x: -500}, 1, {
				ease: FlxEase.cubeIn,
				onComplete: function(twn:FlxTween)
				{
					remove(bgLol);
					remove(songName);
				}
			});

			FlxTween.tween(songName, {x: -500}, 0.9, {
				ease: FlxEase.cubeIn
			});
		});
	}

	override public function update(elapsed)
	{
		super.update(elapsed);
	}
}
