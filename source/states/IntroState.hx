package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import lime.app.Application;

class IntroState extends FlxState
{
	var myName:FlxText;

	override public function create()
	{
		myName = new FlxText(0, 0, FlxG.width, Application.current.meta.get('company'));
		myName.setFormat('assets/data/fonts/karma.TTF', 80, FlxColor.WHITE, CENTER);
		myName.screenCenter();
		myName.bold = true;
		myName.alpha = 0;

		super.create();
		#if !debug
		rollIntro();
		#else
		FlxG.switchState(new MainMenuState());
		#end
	}

	override public function update(elapsed)
	{
		super.update(elapsed);
	}

	function rollIntro()
	{
		add(myName);

		FlxSpriteUtil.fadeIn(myName, 1);
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxSpriteUtil.fadeOut(myName, 1);
			new FlxTimer().start(1.5, function(tmr:FlxTimer) FlxG.switchState(new MainMenuState()));
		});
	}
}
