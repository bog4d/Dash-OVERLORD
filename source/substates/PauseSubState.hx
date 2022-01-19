package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends FlxSubState
{
	var pausedText:FlxText;
	var goBackText:FlxText;

	var options:Array<String> = ['RESUME', 'RESET LEVEL', 'EXIT LEVEL'];
	var optionGROUP:FlxTypedGroup<FlxText>;
	var curSelected:Int;

	public function new()
	{
		super(0x64000000);
		FlxTimer.globalManager.active = false; // bad fix but it works for now
		optionGROUP = new FlxTypedGroup<FlxText>();
		curSelected = 0;

		pausedText = new FlxText(0, 0, FlxG.width, "PAUSED");
		pausedText.setFormat('assets/data/fonts/karma.TTF', 90, FlxColor.WHITE, FlxTextAlign.CENTER);
		pausedText.bold = true;
		pausedText.screenCenter();
		pausedText.y -= 100;
		pausedText.scrollFactor.set(0, 0);

		goBackText = new FlxText(pausedText.x, pausedText.y + 100, FlxG.width, "Press BACKSPACE to go to the main menu");
		goBackText.setFormat('assets/data/fonts/karma.TTF', 30, FlxColor.WHITE, FlxTextAlign.CENTER);
		goBackText.scrollFactor.set(0, 0);

		for (i in 0...options.length)
		{
			var _daOption:FlxText = new FlxText(0, pausedText.y + 95 + i * 50, FlxG.width, options[i]);
			_daOption.setFormat('assets/data/fonts/karma.TTF', 50, FlxColor.WHITE, CENTER);
			// _daOption.antialiasing = true;
			_daOption.alpha = 0.5;
			_daOption.screenCenter(X);
			_daOption.scrollFactor.set(0, 0);

			optionGROUP.add(_daOption);
		}

		add(pausedText);
		if (!PlayState.fromLvSelect)
		{
			var deathsText:FlxText = new FlxText(0, 670, FlxG.width, 'DEATHS: ' + PlayState.deaths);
			deathsText.setFormat('assets/data/fonts/karma.TTF', 30, FlxColor.RED, CENTER);
			deathsText.scrollFactor.set(0, 0);
			#if html5
			deathsText.bold = true;
			#else
			deathsText.setBorderStyle(OUTLINE, FlxColor.RED, 0.5, 1);
			#end
			add(deathsText);
		}
		add(optionGROUP);
		changeSelected(0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, Z]))
		{
			switch (options[curSelected].toLowerCase())
			{
				case 'resume':
					FlxTimer.globalManager.active = true;
					close();
				case 'reset level':
					camera.fade(FlxColor.BLACK, 0.5, false, function()
					{
						FlxTimer.globalManager.active = true;
						FlxG.resetState();
					});

				case 'exit level':
					if (!PlayState.fromLvSelect)
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxTimer.globalManager.active = true;
							FlxG.switchState(new MainMenuState());
						});
					else
						camera.fade(FlxColor.BLACK, 0.5, false, function()
						{
							FlxTimer.globalManager.active = true;
							FlxG.switchState(new LevelSelectState());
						});
			}
		}

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSelected(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSelected(1);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
	}

	function changeSelected(skips:Int)
	{
		curSelected += skips;

		if (curSelected < 0)
			curSelected = optionGROUP.length - 1;
		if (curSelected >= optionGROUP.length)
			curSelected = 0;

		for (i in 0...optionGROUP.length)
		{
			if (i != curSelected)
				optionGROUP.members[i].alpha = 0.5;
			else
				optionGROUP.members[i].alpha = 1;
		}
	}
}
