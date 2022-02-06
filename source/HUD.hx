package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class HUD extends FlxSpriteGroup
{
	public var _vignette:FlxSprite;

	var levelTitle:FlxText;

	public function new()
	{
		super();
		_vignette = new FlxSprite().loadGraphic('assets/images/vignette.png');
		_vignette.color = 0x000000;

		levelTitle = new FlxText(10, 730, FlxG.width / 2, 'Level ' + PlayState.LevelID);
		levelTitle.setFormat('assets/data/fonts/karma.TTF', 30, 0xFFFFFF, LEFT, OUTLINE, 0x000000);
		// Layering
		add(_vignette);
		if (!PlayState.fromLvSelect)
		{
			add(levelTitle);

			FlxTween.tween(levelTitle, {y: 680}, 1, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						FlxTween.tween(levelTitle, {y: 730}, 1, {
							ease: FlxEase.circIn,
							onComplete: function(twn2:FlxTween)
							{
								remove(levelTitle);
							}
						});
					});
				}
			});
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		_vignette.color = FlxColor.interpolate(_vignette.color, 0x000000, 2 * elapsed);
	}
}
