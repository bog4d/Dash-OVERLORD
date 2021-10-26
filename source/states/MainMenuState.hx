package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

class MainMenuState extends FlxState
{
	var UIusable:Bool;
	var fade:FlxSprite;
	var daG:FlxSprite;
	var version = Application.current.meta.get('version');

	var optionGroup:FlxTypedGroup<FlxText>;
	#if !debug
	var txtOptions:Array<String> = ['Play', 'Level select', 'Credits'];
	#else
	var txtOptions:Array<String> = ['Play', 'Level select', 'Credits', 'animation debug menu'];
	#end
	var curSelected:Int;

	override public function create()
	{
		#if windows
		txtOptions.insert(txtOptions.length + 1, 'Quit');
		#end

		FlxG.fixedTimestep = false;
		FlxG.mouse.visible = false;
		UIusable = false;
		curSelected = 0;
		optionGroup = new FlxTypedGroup<FlxText>();

		fade = new FlxSprite().loadGraphic('assets/images/menuFade.png');
		fade.color = FlxColor.BLACK;

		for (i in 0...txtOptions.length)
		{
			var _daOption:FlxText = new FlxText(50, 300 + i * 55, FlxG.width, txtOptions[i]);
			_daOption.setFormat('assets/data/fonts/karma.TTF', 50, FlxColor.WHITE, FlxTextAlign.LEFT);
			_daOption.bold = true;
			_daOption.alpha = 0.5;
			_daOption.antialiasing = true;

			optionGroup.add(_daOption);
		}

		daG = new FlxSprite(800, 250);
		daG.flipX = true;
		daG.antialiasing = true;
		daG.scale.set(1.7, 1.7);
		daG.frames = FlxAtlasFrames.fromSparrow('assets/images/player.png', 'assets/images/player.xml');
		daG.animation.addByPrefix('standingLikeAMenace', 'idle', 24, true);
		daG.animation.play('standingLikeAMenace');

		// Layering

		add(new FlxSprite().loadGraphic('assets/images/menuBg.png'));
		add(daG);
		add(fade);
		var menuLogo:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuLogo.png');
		menuLogo.antialiasing = true;
		add(menuLogo);
		add(optionGroup);
		add(new FlxText(10, 670, FlxG.width, 'v$version').setFormat('assets/data/fonts/karma.TTF', 35, FlxColor.WHITE, FlxTextAlign.LEFT));

		super.create();
		camera.bgColor = FlxColor.WHITE;
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
					case 'play':
						PlayState.deaths = 0;
						PlayState.fromLvSelect = false;
						PlayState.LevelID = 0;
						FlxG.sound.play('assets/sounds/CUT.ogg');
						camera.bgColor = FlxColor.BLACK;
						forEach(function(spr) remove(spr));

						camera.flash(FlxColor.WHITE, 5, function()
						{
							FlxG.switchState(new PlayState());
						});

					case 'level select':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new LevelSelectState());
						});

					case 'credits':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new CreditsState());
						});
					case 'animation debug menu':
						FlxG.sound.play('assets/sounds/confirm.ogg');
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxG.switchState(new AnimTestState());
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
				}
				selectBtnAnim();
			}
		}
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
