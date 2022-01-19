package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class OptionsState extends FlxState
{
	var optionsTitle:FlxText;

	var options:Array<String> = [
		'Camera follow style\n-SCREEN BY SCREEN-',
		'Music\n-ON-',
		'Antialiasing\n-enabled-'
	];
	var optionsGroup:FlxTypedGroup<FlxText>;

	var curSelected:Int;

	var optionValues:Array<Dynamic> = [FlxCameraFollowStyle.SCREEN_BY_SCREEN, true, true];

	var antialiasingPreview:FlxSprite;

	var _settingsSave:FlxSave;

	override public function create()
	{
		curSelected = 0;

		_settingsSave = new FlxSave();
		_settingsSave.bind('Settings');

		if (_settingsSave.data.settings == null)
		{
			_settingsSave.data.settings = [FlxCameraFollowStyle.SCREEN_BY_SCREEN, true, true];
			_settingsSave.flush();
		}

		camera.antialiasing = _settingsSave.data.settings[2];

		optionValues = _settingsSave.data.settings;

		optionsTitle = new FlxText(0, 15, FlxG.width, 'OPTIONS');
		optionsTitle.setFormat('assets/data/fonts/karma.TTF', 100, FlxColor.WHITE, CENTER);
		optionsTitle.bold = true;

		optionsGroup = new FlxTypedGroup<FlxText>();
		for (i in 0...options.length)
		{
			var _option:FlxText = new FlxText(0, 150 + i * 170, FlxG.width, options[i]);
			_option.setFormat('assets/data/fonts/karma.TTF', 64, 0xFFFFFF, CENTER);
			optionsGroup.add(_option);
		}

		antialiasingPreview = new FlxSprite(15, 400);
		antialiasingPreview.frames = FlxAtlasFrames.fromSparrow('assets/images/lostSoul.png', 'assets/images/lostSoul.xml');
		antialiasingPreview.animation.addByPrefix('idle', 'idle', 24, true);
		antialiasingPreview.animation.play('idle');
		antialiasingPreview.visible = false;

		// Layering
		add(new FlxSprite().loadGraphic('assets/images/optionsBg.png'));
		add(optionsTitle);
		add(optionsGroup);
		add(antialiasingPreview);
		super.create();
		camera.bgColor = FlxColor.BLACK;
		changeSelection(0);
		updateVisuals();
		trace(_settingsSave.data.settings);

		camera.fade(FlxColor.BLACK, 0.5, true, function() {});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([UP, W]))
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed([DOWN, S]))
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Z, ENTER, SPACE]))
		{
			FlxG.sound.play('assets/sounds/confirm.ogg');
			switch (curSelected)
			{
				case 0:
					if (optionValues[0] == FlxCameraFollowStyle.SCREEN_BY_SCREEN)
					{
						optionsGroup.members[0].text = 'Camera follow style\n-FOLLOW-';
						optionValues[0] = FlxCameraFollowStyle.PLATFORMER;
					}
					else
					{
						optionsGroup.members[0].text = 'Camera follow style\n-SCREEN BY SCREEN-';
						optionValues[0] = FlxCameraFollowStyle.SCREEN_BY_SCREEN;
					}
				case 1:
					if (optionValues[1] == true)
					{
						optionsGroup.members[1].text = 'Music\n-OFF-';
						optionValues[1] = false;
						if (FlxG.sound.music != null)
							FlxG.sound.music.stop();
					}
					else
					{
						optionsGroup.members[1].text = 'Music\n-ON-';
						optionValues[1] = true;
					}
				case 2:
					if (optionValues[2] == false)
					{
						optionsGroup.members[2].text = 'Antialiasing\n-enabled-';
						optionValues[2] = true;
						camera.antialiasing = true;
					}
					else
					{
						optionsGroup.members[2].text = 'Antialiasing\n-disabled-';
						optionValues[2] = false;
						camera.antialiasing = false;
					}
			}
		}

		if (FlxG.keys.justPressed.R)
		{
			_settingsSave.data.settings = [FlxCameraFollowStyle.SCREEN_BY_SCREEN, true, true];
			optionValues = [FlxCameraFollowStyle.SCREEN_BY_SCREEN, true, true];
			optionsGroup.members[0].text = 'Camera follow style\n-SCREEN BY SCREEN-';
			optionsGroup.members[1].text = 'Music\n-ON-';
			optionsGroup.members[2].text = 'Antialiasing\n-enabled-';
			camera.zoom = 1.1;
			FlxG.sound.play('assets/sounds/ouch.wav');
			trace("RESET ALL SETTINGS TO DEFAULT");
		}
		if (FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE]))
		{
			camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new MainMenuState());
				_settingsSave.data.settings = optionValues;
				_settingsSave.flush(); // Saves only after leaving the options menu.
				trace('saved settings (i think)');
				trace(_settingsSave.data.settings);
			});
		}

		camera.zoom = FlxMath.lerp(camera.zoom, 1, 10 * elapsed);
	}

	function changeSelection(skips:Int)
	{
		curSelected += skips;

		if (curSelected > optionsGroup.length - 1)
			curSelected = optionsGroup.length - 1
		else if (curSelected < 0)
			curSelected = 0;

		for (i in 0...optionsGroup.length)
		{
			if (i != curSelected)
				optionsGroup.members[i].alpha = 0.5;
			else
				optionsGroup.members[i].alpha = 1;
		}

		if (curSelected == 2)
			antialiasingPreview.visible = true;
		else
			antialiasingPreview.visible = false;
	}

	function updateVisuals()
	{
		if (optionValues[0] == FlxCameraFollowStyle.SCREEN_BY_SCREEN)
		{
			optionsGroup.members[0].text = 'Camera follow style\n-SCREEN BY SCREEN-';
			optionValues[0] = FlxCameraFollowStyle.SCREEN_BY_SCREEN;
			_settingsSave.data.settings[0] = FlxCameraFollowStyle.SCREEN_BY_SCREEN;
		}
		else
		{
			optionsGroup.members[0].text = 'Camera follow style\n-FOLLOW-';
			optionValues[0] = FlxCameraFollowStyle.PLATFORMER;
			_settingsSave.data.settings[0] = FlxCameraFollowStyle.PLATFORMER;
		}

		if (optionValues[1] == true)
		{
			optionsGroup.members[1].text = 'Music\n-ON-';
			optionValues[1] = true;
			_settingsSave.data.settings[1] = true;
		}
		else
		{
			optionsGroup.members[1].text = 'Music\n-OFF-';
			optionValues[1] = false;
			_settingsSave.data.settings[1] = false;
		}

		if (optionValues[2] == false)
		{
			optionsGroup.members[2].text = 'Antialiasing\n-disabled-';
			optionValues[2] = false;
			_settingsSave.data.settings[2] = false;
		}
		else
		{
			optionsGroup.members[2].text = 'Antialiasing\n-enabled-';
			optionValues[2] = true;
			_settingsSave.data.settings[2] = true;
		}
	}
}
