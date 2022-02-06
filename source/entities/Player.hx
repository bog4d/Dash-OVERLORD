package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	public static var MovementEnabled:Bool;

	public var fsm:FSM;

	var rightKeys:Array<FlxKey> = ["RIGHT", "D"];
	var leftKeys:Array<FlxKey> = ["LEFT", "A"];
	var jumpKeys:Array<FlxKey> = ["SPACE", "W", "UP"];
	var dashKeys:Array<FlxKey> = ["Z", "SHIFT"];

	final _acceleration = 600;

	var dashCooldown:Bool;

	public static var isDashing:Bool;

	var dashTrail:FlxTrail;

	var daSpeed = 400;

	public function new()
	{
		super();
		isDashing = false;
		MovementEnabled = false; // wait for fade
		dashCooldown = false;

		// Appearence
		frames = FlxAtlasFrames.fromSparrow('assets/images/player.png', 'assets/images/player.xml');
		scale.set(0.3, 0.3);
		setSize(42.9, 108.9);
		// antialiasing = true;
		animation.play('idle');

		animation.addByPrefix('idle', 'idle', 24, true);
		animation.addByPrefix('walk', 'walk', 24, true);
		animation.addByPrefix('respawn', 'respawn ouch', 24, false);
		animation.addByPrefix('slash', 'slash', 35, false);
		animation.addByPrefix('wake', 'wake up', 24, false);
		animation.play('idle');

		acceleration.y = PlayState.GRAVITY;
		maxVelocity.x = daSpeed; // basically the max speed :)
		drag.x = _acceleration * 5;
		hitboxFix();

		fsm = new FSM(idle);

		animation.finishCallback = function(animName:String)
		{
			if (animName == 'respawn')
			{
				fsm.activeState = idle;
				MovementEnabled = true;
			}
		}
	}

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick('Player location', getPosition());
		// this update function makes me wanna cry :/

		if (MovementEnabled)
		{
			/*
				if (FlxG.keys.anyPressed(rightKeys))
				{
					acceleration.x = _acceleration;
					flipX = false;
					animation.play('walk');
				}
				else if (FlxG.keys.anyPressed(leftKeys))
				{
					acceleration.x = -_acceleration;
					flipX = true;
					animation.play('walk');
				}
				else
				{
					acceleration.x = 0;
					velocity.x = 0;
					animation.play('idle');
				}
			 */

			if (FlxG.keys.anyJustPressed(jumpKeys) && isTouching(FlxObject.FLOOR))
			{
				velocity.y = -PlayState.GRAVITY / 2;
				scale.set(0.25, 0.35);
			}
		}

		// Dashin'
		if (FlxG.keys.anyJustPressed(dashKeys) && !dashCooldown && MovementEnabled)
		{
			scale.x = 0.8; // cool thing (handled by lerp)

			MovementEnabled = false;
			isDashing = true;

			animation.play('slash', true);
			final dashSpeed = 2200;
			maxVelocity.x = dashSpeed;

			dashWait(0.5);

			FlxG.sound.play('assets/sounds/dash.wav');
			FlxG.camera.shake(0.01, 0.1);
			if (!flipX)
				velocity.x = dashSpeed;
			else
				velocity.x = -dashSpeed;
		}
		fsm.update(elapsed);
		super.update(elapsed);

		FlxG.watch.addQuick('playerVelocity X', velocity.x);
		FlxG.watch.addQuick('Movement enabled', MovementEnabled);
		hitboxFix();

		scale.set(FlxMath.lerp(scale.x, 0.3, 15 * elapsed), FlxMath.lerp(scale.y, 0.3, 15 * elapsed));
		/*
			if (NarratorSpeak.isInProgress)
			{
				MovementEnabled = false;
				acceleration.x = 0;
				velocity.x = 0;
			}
		 */
	}

	function dashWait(cooldownTime:Float)
	{
		dashCooldown = true;
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			isDashing = false;
			if (!NarratorSpeak.isInProgress)
				MovementEnabled = true;
			velocity.x = 0;
			acceleration.x = 0;
			maxVelocity.x = daSpeed;

			new FlxTimer().start(cooldownTime, function(tmr:FlxTimer)
			{
				dashCooldown = false;
			});
		});
	}

	function hitboxFix()
	{
		// NOT FlipX
		if (!flipX)
		{
			switch (animation.curAnim.name)
			{
				case 'idle':
					offset.x = 70.1;
					offset.y = 147.95;
				case 'walk':
					offset.x = 70.1;
					offset.y = 147.95;
				case 'respawn':
					offset.x = 97.1;
					offset.y = 147.95;
				case 'slash':
					offset.x = 114;
					offset.y = 147.95;
				case 'wake':
					offset.x = 84;
					offset.y = 145.95;
			}
		}
		else
		{
			switch (animation.curAnim.name)
			{
				case 'idle':
					offset.x = 73.1;
					offset.y = 147.95;
				case 'walk':
					offset.x = 73.1;
					offset.y = 147.95;
				case 'slash':
					offset.x = 29;
					offset.y = 147.95;
			}
		}
		/*
			// NOT FlipX
			if (animation.curAnim.name == 'idle' && !flipX)
				offset.x = 70.1;

			if (animation.curAnim.name == 'walk' && !flipX)
				offset.x = 70.1;

			if (animation.curAnim.name == 'respawn' && !flipX)
				offset.x = 97.1;

			//FlipX
						if (animation.curAnim.name == 'idle' && flipX)
				offset.x = 73.1;

			if (animation.curAnim.name == 'walk' && flipX)
				offset.x = 73.1;
		 */
	}

	//-----[STATES]-----\\
	function idle(elapsed:Float)
	{
		final allMoveKeys:Array<FlxKey> = leftKeys.concat(rightKeys); // oooo this concat thing is neat
		acceleration.x = 0;

		if (MovementEnabled)
		{
			animation.play('idle');
			if (FlxG.keys.anyPressed(allMoveKeys))
				fsm.activeState = move;
		}
	}

	function move(elapsed:Float)
	{
		if (FlxG.keys.anyPressed(rightKeys))
		{
			acceleration.x = _acceleration;
			flipX = false;
			animation.play('walk');
		}
		else if (FlxG.keys.anyPressed(leftKeys))
		{
			acceleration.x = -_acceleration;
			flipX = true;
			animation.play('walk');
		}
		else
			fsm.activeState = idle;

		if (!MovementEnabled)
			fsm.activeState = idle;

		if (!MovementEnabled && isDashing)
			animation.play('slash', true);
	}

	public function hit(elapsed:Float)
	{
		acceleration.x = 0;
		velocity.x = 0;
		flipX = false;
		animation.play('respawn');
	}
}