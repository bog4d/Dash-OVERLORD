package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class CreditsState extends FlxState
{
	var title:FlxText;
	var backText:FlxText;
	var credits:Array<String> = [
		'Created by Bogdan2D',
		'Music by Eric Skiff',
		'Developed with HaxeFlixel',
		'Initially made in 1 week for HaxeJam 2021 <3'
	];

	override public function create()
	{
		title = new FlxText(0, 25, FlxG.width, "CREDITS").setFormat('assets/data/fonts/karma.TTF', 100, FlxColor.BLACK, CENTER);
		title.bold = true;
		title.antialiasing = true;
		add(title);

		backText = new FlxText(0, 690, FlxG.width, "Press BACKSPACE to go back").setFormat('assets/data/fonts/karma.TTF', 20, FlxColor.BLACK, CENTER);
		backText.bold = true;
		backText.antialiasing = true;
		add(backText);
		add(new FlxSprite().loadGraphic('assets/images/cosmnCred.png'));
		for (i in 0...credits.length)
		{
			var _text:FlxText = new FlxText(10, title.y + 120 + i * 60, FlxG.width, credits[i]);
			_text.setFormat('assets/data/fonts/karma.TTF', 50, FlxColor.BLACK, CENTER);
			_text.antialiasing = true;
			_text.scrollFactor.set(0.5, 0.5);
			add(_text);
		}
		super.create();
		camera.fade(FlxColor.BLACK, 0.5, true);
		camera.zoom = 2;
		FlxTween.tween(camera, {zoom: 1}, 2, {
			ease: FlxEase.circInOut
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.BACKSPACE)
		{
			camera.fade(FlxColor.BLACK, 0.5, false, function()
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;
	}
}
