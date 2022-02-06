package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;

class LostSoul extends FlxSprite
{
	final speed = -200;
	var fsm:FSM;

	public function new()
	{
		super();
		flipX = true;
		frames = FlxAtlasFrames.fromSparrow('assets/images/lostSoul.png', 'assets/images/lostSoul.xml');
		scale.set(0.3, 0.3);
		velocity.x = speed;
		offset.y = 134.95;
		setSize(40.9, 108.9);
		acceleration.y = PlayState.GRAVITY;
		animation.addByPrefix('walk', 'walk', 24, true);
		hitboxFix();

		// FSM
		fsm = new FSM(move);
	}

	override public function update(elapsed:Float)
	{
		if (isTouching(FlxObject.UP) && isTouching(FlxObject.FLOOR))
		{
			velocity.y = -PlayState.GRAVITY / 3;
		}

		fsm.update(elapsed);
		super.update(elapsed);
	}

	function hitboxFix()
	{
		if (animation.curAnim.name == 'walk' && !flipX)
			offset.x = 71.1;

		if (animation.curAnim.name == 'walk' && flipX)
			offset.x = 90.1;
	}

	//-----[STATES]-----\\
	function idle(elapsed:Float)
	{
		animation.play('idle');
	}

	function move(elapsed:Float)
	{
		animation.play('walk'); // update the current animation (It's too choppy :/)
		if (isTouching(FlxObject.RIGHT))
		{
			velocity.x = speed;
			flipX = true;
			hitboxFix();
		}
		if (isTouching(FlxObject.LEFT))
		{
			velocity.x = -speed;
			flipX = false;
			hitboxFix();
		}
	}
}
