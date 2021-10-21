package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.utils.Assets;

class LevelSelectState extends FlxState
{
	var UIusable:Bool;
	var curSelected:Int;
	var fade:FlxSprite;
	var title:FlxText;
	var lvGroup:FlxTypedGroup<FlxText>;
	var levels:Int = Std.parseInt(Assets.getText('assets/data/levels/levels.txt')); // if you put a letter in that text file you sinned >:(

	override public function create()
	{
		UIusable = false;
		curSelected = 0;
		lvGroup = new FlxTypedGroup<FlxText>();
		title = new FlxText(10, 10, FlxG.width, "LEVEL SELECT").setFormat('assets/data/fonts/karma.TTF', 100, FlxColor.WHITE, LEFT);
		title.bold = true;

		for (i in 0...levels + 1)
		{
			var _text:FlxText = new FlxText(10, title.y + 110 + i * 55, FlxG.width, 'Level $i');
			_text.setFormat('assets/data/fonts/karma.TTF', 50, FlxColor.WHITE, FlxTextAlign.LEFT);
			_text.antialiasing = true;
			_text.alpha = 0.5;
			lvGroup.add(_text);

			if (_text.text == 'Level 0')
				_text.text = 'TUTORIAL';
		}

		fade = new FlxSprite().loadGraphic('assets/images/lvSelectFade.png');
		fade.color = FlxColor.BLACK;
		add(new FlxSprite().loadGraphic('assets/images/lvSelectImg.png'));
		add(fade);
		add(title);
		add(lvGroup);
		super.create();
		camera.fade(FlxColor.BLACK, 0.5, true, function()
		{
			UIusable = true;
			changeSelectedLv(0);
		});
		camera.bgColor = FlxColor.WHITE;
	}

	override public function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([W, UP]))
			changeSelectedLv(-1);
		if (FlxG.keys.anyJustPressed([S, DOWN]))
			changeSelectedLv(1);

		if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]))
		{
			UIusable = false;
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		if (FlxG.keys.anyJustPressed([ENTER, SPACE, Z]))
		{
			if (UIusable)
			{
				UIusable = false;
				FlxG.sound.play('assets/sounds/confirm.ogg');

				// PlayState.hasDied = false;
				PlayState.fromLvSelect = true;
				PlayState.LevelID = curSelected;
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function() FlxG.switchState(new PlayState()));

				FlxTween.tween(lvGroup.members[curSelected], {x: lvGroup.members[curSelected].x + 15}, 0.5, {
					ease: FlxEase.backOut
				});
				lvGroup.members[curSelected].color = FlxColor.RED;
			}
		}
	}

	function changeSelectedLv(skips:Int)
	{
		if (UIusable)
		{
			curSelected += skips;

			if (curSelected < 0)
				curSelected = lvGroup.length - 1;
			if (curSelected >= lvGroup.length)
				curSelected = 0;

			for (i in 0...lvGroup.length)
			{
				if (i != curSelected)
					lvGroup.members[i].alpha = 0.5;
				else
					lvGroup.members[i].alpha = 1;
			}
		}
	}
}
