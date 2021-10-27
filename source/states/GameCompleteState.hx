package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class GameCompleteState extends FlxState
{
	var bg:FlxSprite;
	var him:FlxSprite;
	var knife:FlxSprite;
	var daText:FlxSprite;

	override public function create()
	{
		bg = new FlxSprite().loadGraphic('assets/images/end/bg.png');
		bg.scrollFactor.set(0, 0);
		bg.antialiasing = true;
		him = new FlxSprite().loadGraphic('assets/images/end/him.png');
		him.angle = 15;
		him.antialiasing = true;
		knife = new FlxSprite().loadGraphic('assets/images/end/daKnife.png');
		knife.antialiasing = true;
		knife.angle = -45;
		daText = new FlxSprite().loadGraphic('assets/images/end/text.png');
		daText.antialiasing = true;
		daText.alpha = 0;

		if (PlayState.deaths == 0)
		{
			bg.loadGraphic('assets/images/end/bgMenace.png');
			him.loadGraphic('assets/images/end/himMenace.png');
			daText.loadGraphic('assets/images/end/textMenace.png');
		}

		camera.zoom = 2;
		camera.scroll.x -= 500;

		add(bg);
		add(him);
		add(knife);
		add(daText);
		super.create();

		// MEDALS
		if (PlayState.deaths > 0)
		{
			NGio.unlockMedal(65906);
			checkIfLocked(65906, "DASH OVERLORD", "Beat the game.");
		}
		else
		{
			NGio.unlockMedal(65952);
			checkIfLocked(65952, "MENACE", "Beat the game with NO deaths!");
		}

		// Tweens
		FlxTween.tween(knife, {angle: 0}, 5, {
			ease: FlxEase.circInOut
		});

		FlxTween.tween(him, {angle: 0}, 5, {
			ease: FlxEase.circInOut
		});

		FlxTween.tween(camera, {zoom: 1}, 5, {
			ease: FlxEase.circInOut,
			onComplete: function(twn:FlxTween)
			{
				FlxSpriteUtil.fadeIn(daText);
			}
		});

		FlxTween.tween(camera.scroll, {x: 0}, 5, {
			ease: FlxEase.circInOut
		});
		camera.fade(FlxColor.BLACK, 0.5, true);
	}

	override public function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.BACKSPACE)
		{
			camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new MainMenuState());
			});
		}
	}

	function checkIfLocked(id:Int, medName:String, medDesc:String)
	{
		if (PlayState.isMedalLocked)
		{
			var popup:MedalPopup = new MedalPopup(id, medName, medDesc);
			add(popup);
		}
	}
}
