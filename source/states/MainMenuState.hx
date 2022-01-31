package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import lime.app.Application;

class MainMenuState extends FlxState
{
	public static var firstPlay:Bool;

	var UIusable:Bool;
	var fade:FlxSprite;
	var version = Application.current.meta.get('version');

	var optionGroup:FlxTypedGroup<FlxText>;
	#if !debug
	var txtOptions:Array<String> = ['New Game', 'Level select', 'Options', 'Credits', 'Donate'];
	#else
	var txtOptions:Array<String> = ['New Game', 'Level select', 'Credits', 'Options', 'Donate', 'anim debug'];
	#end
	var curSelected:Int;

	var _settingsSave:FlxSave;

	var bg1:FlxSprite;
	var bg2:FlxSprite;

	override public function create()
	{
		#if windows
		txtOptions.insert(txtOptions.length + 1, 'Quit');
		#end

		_settingsSave = new FlxSave();
		_settingsSave.bind('Settings');

		camera.antialiasing = _settingsSave.data.settings[2];

		FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;
		UIusable = false;
		curSelected = 0;
		optionGroup = new FlxTypedGroup<FlxText>();

		for (i in 0...txtOptions.length)
		{
			var _daOption:FlxText = new FlxText(-340, 300 + i * 55, FlxG.width, txtOptions[i]);
			_daOption.setFormat('assets/data/fonts/karma.TTF', 50, FlxColor.WHITE, CENTER);
			_daOption.bold = true;
			_daOption.alpha = 0.5;
			// _daOption.antialiasing = true;

			optionGroup.add(_daOption);
		}

		bg1 = new FlxSprite(-295, -50).loadGraphic('assets/images/menu/1.png');
		bg2 = new FlxSprite(-280).loadGraphic('assets/images/menu/2.png');
		// Layering
		var daBackDrop = new FlxBackdrop('assets/images/backdrop.png', 0.5, 0.5);
		daBackDrop.velocity.set(10, -10);
		add(daBackDrop);
		add(bg2);
		add(bg1);
		var vignette = new FlxSprite().loadGraphic('assets/images/vignette.png');
		vignette.color = 0x000000;
		add(vignette);
		add(new FlxSprite(120).makeGraphic(380, 720, 0x64000000));
		add(new FlxSprite().loadGraphic('assets/images/menuLogo.png'));
		add(optionGroup);
		add(new FlxText(10, 670, FlxG.width, 'v$version').setFormat('assets/data/fonts/karma.TTF', 35, FlxColor.WHITE, FlxTextAlign.LEFT));

		//------------------\\
		super.create();
		camera.bgColor = FlxColor.WHITE;
		//------------------\\
		camera.fade(FlxColor.BLACK, 0.5, true, function()
		{
			UIusable = true;
			changeSelection(0);
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.watch.addQuick("UI usable ?", UIusable);

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, Z]))
		{
			if (UIusable)
			{
				UIusable = false;
				switch (txtOptions[curSelected].toLowerCase())
				{
					case 'new game':
						PlayState.deaths = 0;
						PlayState.fromLvSelect = false;
						PlayState.LevelID = 0;

						if (firstPlay)
						{
							firstPlay = false;
							FlxG.sound.play('assets/sounds/CUT.ogg');
							camera.bgColor = FlxColor.BLACK;
							forEach(function(spr) remove(spr));
							camera.flash(FlxColor.WHITE, 5, function()
							{
								FlxG.switchState(new PlayState());
							});
						}
						else
						{
							FlxG.sound.play('assets/sounds/confirm.ogg');
							camera.fade(FlxColor.BLACK, 0.5, false, function() FlxG.switchState(new PlayState()));
						}

					case 'level select':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new LevelSelectState());
						});
					case 'options':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new OptionsState());
						});

					case 'credits':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new CreditsState());
						});
					case 'anim debug':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new AnimTestState());
						});
					case 'donate':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						FlxG.openURL('https://bogdan2d.itch.io/dash-overlord');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.resetState();
						});
					case 'quit':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							#if cpp
							Sys.exit(0);
							#end
						});
					default:
						FlxG.sound.play('assets/sounds/confirm.ogg');
						FlxG.log.warn('This button does nothing. Did you put it in the switch case?');
				}
				selectBtnAnim();
			}
		}

		bg1.y = FlxMath.lerp(bg1.y, -150 * curSelected / 10 - 270, 2 * elapsed);
		bg2.y = FlxMath.lerp(bg2.y, -50 * curSelected / 10 - 200, 2 * elapsed);
	}

	function changeSelection(skips:Int)
	{
		if (UIusable)
		{
			curSelected += skips;

			if (curSelected < 0)
				curSelected = optionGroup.length - 1;
			if (curSelected >= optionGroup.length)
				curSelected = 0;

			for (i in 0...optionGroup.length)
			{
				if (i != curSelected)
					optionGroup.members[i].alpha = 0.5;
				else
					optionGroup.members[i].alpha = 1;
			}
		}
	}

	function selectBtnAnim()
	{
		FlxTween.tween(optionGroup.members[curSelected], {x: optionGroup.members[curSelected].x + 15}, 0.5, {
			ease: FlxEase.backOut
		});
		optionGroup.members[curSelected].color = FlxColor.RED;
	}
}
