package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseSubState extends FlxSubState
{
	var pausedText:FlxText;
	var goBackText:FlxText;

	public function new()
	{
		super(0x64000000);
		FlxTimer.globalManager.active = false; // bad fix but it works for now

		pausedText = new FlxText(0, 0, FlxG.width, "PAUSED");
		pausedText.setFormat('assets/data/fonts/karma.TTF', 64, FlxColor.WHITE, FlxTextAlign.CENTER);
		pausedText.bold = true;
		pausedText.screenCenter();
		pausedText.scrollFactor.set(0, 0);

		goBackText = new FlxText(pausedText.x, pausedText.y + 75, FlxG.width, "Press BACKSPACE to go to the main menu");
		goBackText.setFormat('assets/data/fonts/karma.TTF', 20, FlxColor.WHITE, FlxTextAlign.CENTER);
		goBackText.scrollFactor.set(0, 0);

		add(pausedText);
		add(goBackText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([ENTER, ESCAPE]))
		{
			FlxTimer.globalManager.active = true;
			close();
		}

		if (FlxG.keys.justPressed.BACKSPACE)
		{
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
		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
	}
}
