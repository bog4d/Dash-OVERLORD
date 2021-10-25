package;

import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class NarratorSpeak extends FlxSpriteGroup
{
	public static var isInProgress:Bool;

	var lines:Array<String>;
	var typeText:FlxTypeText;
	var curPart:Int = 0;
	var doneText:FlxText;

	public function new(fileName)
	{
		super();
		isInProgress = true;
		curPart = 0;
		lines = TextUtil.arrayifyTextFile('assets/data/levels/' + PlayState.LevelID + '/$fileName.txt');
		typeText = new FlxTypeText(0, 300, 500, lines[curPart]);
		typeText.setFormat('assets/data/fonts/karma.TTF', 40, FlxColor.BLACK, CENTER);
		typeText.screenCenter(X);
		typeText.antialiasing = true;
		typeText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);

		doneText = new FlxText(0, typeText.y - 25, "Press ENTER to continue");
		doneText.setFormat('assets/data/fonts/karma.TTF', 20, FlxColor.BLACK, CENTER);
		doneText.screenCenter(X);
		doneText.antialiasing = true;
		doneText.setBorderStyle(OUTLINE, FlxColor.WHITE, 2);
		add(doneText);
		// typeText.sounds = [FlxG.sound.load('assets/sounds/dialogBeep.wav')];
		add(typeText);
		proceedDialog();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
			proceedDialog();
	}

	function proceedDialog()
	{
		curPart++;
		if (lines[curPart] != null)
		{
			doneText.visible = false;
			typeText.resetText(lines[curPart]);
			typeText.start(0.05, true, false, [FlxKey.SHIFT], onTextComplete);
			Player.MovementEnabled = false;
		}
		else
		{
			remove(typeText);
			remove(doneText);
			Player.MovementEnabled = true;
			isInProgress = false;
		}
	}

	function onTextComplete()
	{
		doneText.visible = true;
	}
}
