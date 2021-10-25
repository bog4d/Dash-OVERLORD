package;

import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class GameCompleteState extends FlxState
{
	override public function create()
	{
		add(new FlxSprite().loadGraphic('assets/images/GameEndScreen.png'));
		var backText:FlxText = new FlxText(0, 690, FlxG.width,
			"Press BACKSPACE to go back to the main menu").setFormat('assets/data/fonts/karma.TTF', 20, FlxColor.BLACK, CENTER);
		backText.bold = true;
		backText.antialiasing = true;
		add(backText);
		super.create();
		NGio.unlockMedal(65906);
		checkIfLocked(65906, "DASH OVERLORD", "Beat the game!");
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
