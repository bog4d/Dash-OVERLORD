package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
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
	var _gameSave:FlxSave;

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

		_gameSave = new FlxSave();
		_gameSave.bind('GameSave');

		if (_settingsSave.data.settings == null)
		{
			_settingsSave.data.settings = [FlxCameraFollowStyle.PLATFORMER, true, true];
			_settingsSave.flush();
		}

		if (_gameSave.data.curLevel == null)
			_gameSave.data.curLevel = 0;

		if (_gameSave.data.finishedOnce == null)
			_gameSave.data.finishedOnce = false;

		if (_gameSave.data.bestTimes == null)
		{
			_gameSave.data.bestTimes = new Map<Int, Float>();
			BestTime.bestTimes = _gameSave.data.bestTimes;
		}
		BestTime.bestTimes = _gameSave.data.bestTimes;

		_gameSave.flush();
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
		//-----[Cache graphics]-----\\
		FlxGraphic.fromAssetKey('assets/images/player.png').persist = true;
		FlxGraphic.fromAssetKey('assets/images/lostSoul.png').persist = true;
		FlxGraphic.fromAssetKey('assets/images/tileset.png').persist = true;
		FlxGraphic.fromAssetKey('assets/images/spike.png').persist = true;
		FlxGraphic.fromAssetKey('assets/images/spikeHit.png').persist = true;
		//---------------------------\\
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
