package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.app.Application;

class IntroState extends FlxState
{
	var backdrop:FlxSprite;
	var myName:FlxText;

	var _settingsSave:FlxSave;

	override public function create()
	{
		#if !debug
		MainMenuState.firstPlay = true;
		#else
		MainMenuState.firstPlay = false;
		#end

		FlxG.mouse.visible = false;

		// SAVE DATA (Btw SoLo is pateu)
		_settingsSave = new FlxSave();
		_settingsSave.bind('Settings');

		if (_settingsSave.data.settings == null)
		{
			_settingsSave.data.settings = [FlxCameraFollowStyle.SCREEN_BY_SCREEN, true, true];
			_settingsSave.flush();
		}
		//-----------------------------------\\

		new NGio(SecretHA.ID, SecretHA.ENC_KEY);

		FlxG.fixedTimestep = false;

		backdrop = new FlxSprite();
		backdrop.loadGraphic('assets/images/introBg.png');
		backdrop.alpha = 0;

		myName = new FlxText(0, 0, FlxG.width, Application.current.meta.get('company'));
		myName.setFormat('assets/data/fonts/karma.TTF', 80, FlxColor.WHITE, CENTER);
		myName.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 5);
		// myName.antialiasing = true;

		myName.screenCenter();
		myName.bold = true;
		myName.alpha = 0;

		super.create();
		camera.antialiasing = _settingsSave.data.settings[2];

		#if !debug
		rollIntro();
		#else
		#if !lv
		FlxG.switchState(new MainMenuState());
		#else
		FlxG.switchState(new LevelSelectState());
		#end
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
