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
	var lvGroup:FlxTypedGroup<LevelButton>;
	var levels:Int = Std.parseInt(TextUtil.arrayifyTextFile('assets/data/levels/levelData.txt')[0]); // if you put a letter in that text file you sinned >:(

	override public function create()
	{
		UIusable = false;
		curSelected = 0;
		lvGroup = new FlxTypedGroup<LevelButton>();
		title = new FlxText(10, 10, FlxG.width, "LEVEL SELECT").setFormat('assets/data/fonts/karma.TTF', 100, FlxColor.WHITE, LEFT);
		#if html5
		title.bold = true;
		#else
		title.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.WHITE, 2);
		#end

		for (i in 0...levels + 1)
		{
			var _text:LevelButton = new LevelButton(10 + i * 5, 10, i);
			_text.daY = i;
			lvGroup.add(_text);
		}

		fade = new FlxSprite().loadGraphic('assets/images/lvSelectFade.png');
		fade.color = FlxColor.BLACK;
		var bgImage:FlxSprite = new FlxSprite(150, 0).loadGraphic('assets/images/lvSelectImg.png');
		bgImage.antialiasing = true;
		add(bgImage);
		add(fade);
		add(lvGroup);
		add(new FlxSprite().makeGraphic(670, 140, 0x90000000));
		add(title);
		super.create();

		camera.fade(FlxColor.BLACK, 0.5, true, function()
		{
			UIusable = true;
			changeSelectedLv(0);
		});
		FlxTween.tween(bgImage, {x: 0}, 1, {
			ease: FlxEase.cubeOut
		});
		camera.bgColor = FlxColor.BLACK;
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
		var moveBy:Float = Std.parseFloat(TextUtil.arrayifyTextFile('assets/data/levels/levelData.txt')[1]); // Higher number means it scrolls more
		if (UIusable)
		{
			curSelected += skips;

			if (curSelected < 0)
			{
				curSelected++;
				for (lvThing in lvGroup.members)
					lvThing.daY -= moveBy;
			}
			if (curSelected >= lvGroup.length)
			{
				curSelected--;
				for (lvThing in lvGroup.members)
					lvThing.daY += moveBy;
			}

			for (i in 0...lvGroup.length)
			{
				if (i != curSelected)
					lvGroup.members[i].alpha = 0.5;
				else
					lvGroup.members[i].alpha = 1;
			}

			for (lvThing in lvGroup.members)
			{
				if (skips > 0)
					lvThing.daY -= moveBy;
				else
					lvThing.daY += moveBy;
			}
		}
	}
}
