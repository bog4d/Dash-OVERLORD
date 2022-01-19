package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;

class MedalPopup extends FlxSpriteGroup
{
	var unlockBG:FlxSprite;
	var medalImage:FlxSprite;
	var unlockText:FlxText;
	var medalNameTxt:FlxText;
	var medalDescTxt:FlxText;

	public function new(id:Int, ?medalName:String, ?medalDesc:String) // i have no idea how to fetch the medal name and desc from NG servers D:
	{
		super();

		unlockBG = new FlxSprite(-500, 15).loadGraphic('assets/images/MedalUnlockBox.png');
		// unlockBG.antialiasing = true;

		medalImage = new FlxSprite().loadGraphic('assets/images/medals/$id.png');
		// medalImage.antialiasing = true;

		unlockText = new FlxText(0, 0, FlxG.width, "Medal unlocked!");
		unlockText.setFormat('assets/data/fonts/karma.TTF', 25, FlxColor.YELLOW, LEFT);
		// unlockText.antialiasing = true;

		medalNameTxt = new FlxText(0, 0, FlxG.width, medalName);
		medalNameTxt.setFormat('assets/data/fonts/karma.TTF', 20, FlxColor.WHITE, LEFT);
		// medalNameTxt.antialiasing = true;

		medalDescTxt = new FlxText(0, 0, 300, medalDesc);
		medalDescTxt.setFormat('assets/data/fonts/karma.TTF', 15, FlxColor.WHITE, LEFT);
		// medalDescTxt.antialiasing = true;

		add(unlockBG);
		add(medalImage);
		add(unlockText);
		add(medalNameTxt);
		add(medalDescTxt);

		FlxTween.tween(unlockBG, {x: 15}, 1, {
			ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					FlxTween.tween(unlockBG, {x: -500}, 1, {
						ease: FlxEase.circIn,
						onComplete: function(twn:FlxTween)
						{
							remove(unlockBG);
							remove(medalImage);
							remove(unlockText);
							remove(medalNameTxt);
							remove(medalDescTxt);
						}
					});
				});
			}
		});
	}

	override public function update(elapsed)
	{
		super.update(elapsed);
		medalImage.setPosition(unlockBG.x + 30, unlockBG.y + 23);
		unlockText.setPosition(unlockBG.x + 125, unlockBG.y + 15);
		medalNameTxt.setPosition(unlockBG.x + 125, unlockBG.y + 45);
		medalDescTxt.setPosition(unlockBG.x + 125, unlockBG.y + 67);
	}
}
