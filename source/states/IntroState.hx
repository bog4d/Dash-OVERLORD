package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.app.Application;

class IntroState extends FlxState
{
	var backdrop:FlxSprite;
	var myName:FlxText;

	override public function create()
	{
		MainMenuState.firstPlay = true;
		FlxG.mouse.visible = false;
		new NGio(SecretHA.ID, SecretHA.ENC_KEY);

		FlxG.fixedTimestep = false;

		backdrop = new FlxSprite();
		backdrop.loadGraphic('assets/images/introBg.png');
		backdrop.alpha = 0;

		myName = new FlxText(0, 0, FlxG.width, Application.current.meta.get('company'));
		myName.setFormat('assets/data/fonts/karma.TTF', 80, FlxColor.WHITE, CENTER);
		myName.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5);
		myName.antialiasing = true;

		myName.screenCenter();
		myName.bold = true;
		myName.alpha = 0;

		super.create();

		#if !debug
		rollIntro();
		#else
		FlxG.switchState(new MainMenuState());
		#end
	}

	override public function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
	}

	function rollIntro()
	{
		add(backdrop);
		add(myName);

		FlxSpriteUtil.fadeIn(myName, 1);
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			// FlxSpriteUtil.fadeOut(myName, 1);
			FlxG.camera.fade(FlxColor.BLACK, 1.5, false, function()
			{
				FlxG.switchState(new MainMenuState());
			});
			// new FlxTimer().start(1.5, function(tmr:FlxTimer) FlxG.switchState(new MainMenuState()));
		});

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			FlxSpriteUtil.fadeIn(backdrop, 1);
			FlxTween.tween(backdrop, {x: backdrop.x - 50}, 5, {
				ease: FlxEase.linear
			});
		});
	}
}
