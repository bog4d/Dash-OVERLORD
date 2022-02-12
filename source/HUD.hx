package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class HUD extends FlxSpriteGroup
{
	public var _vignette:FlxSprite;

	var levelTitle:FlxText;

	public var stopwatchText:FlxText;

	public function new()
	{
		super();
		_vignette = new FlxSprite().loadGraphic('assets/images/vignette.png');
		_vignette.color = 0x000000;

		levelTitle = new FlxText(10, 730, FlxG.width / 2, 'Level ' + PlayState.LevelID);
		levelTitle.setFormat('assets/data/fonts/karma.TTF', 30, 0xFFFFFF, LEFT, OUTLINE, 0x000000);

		stopwatchText = new FlxText(10, 10, FlxG.width, Std.int(PlayState.stopwatch.elapsedTime));
		stopwatchText.setFormat('assets/data/fonts/karma.TTF', 40, 0xFFFFFF, LEFT, OUTLINE, 0x000000);
		stopwatchText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		stopwatchText.alpha = 0.5;
		// Layering
		add(_vignette);
		add(stopwatchText);
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
		stopwatchText.color = FlxColor.interpolate(stopwatchText.color, 0xFFFFFF, 2 * elapsed);
		stopwatchText.text = "" + FlxMath.roundDecimal(PlayState.stopwatch.elapsedTime, 2); // Std.int(PlayState.stopwatch.elapsedTime);
	}
}
