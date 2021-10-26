package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	public static var MovementEnabled:Bool;

	var rightKeys:Array<FlxKey> = ["RIGHT", "D"];
	var leftKeys:Array<FlxKey> = ["LEFT", "A"];
	var jumpKeys:Array<FlxKey> = ["SPACE", "W", "UP"];
	var dashKeys:Array<FlxKey> = ["Z", "SHIFT"];

	var _acceleration = 600;

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
		antialiasing = true;
		animation.play('idle');

		animation.addByPrefix('idle', 'idle', 24, true);
		animation.addByPrefix('walk', 'walk', 24, true);
		animation.addByPrefix('respawn', 'respawn ouch', 24, false);
		animation.addByPrefix('slash', 'slash', 35, false);
		animation.addByPrefix('wake', 'wake up', 24, false);
		animation.play('idle');

		acceleration.y = PlayState.GRAVITY;
		maxVelocity.x = daSpeed; // basically the max speed :)
		hitboxFix();
	}

	override public function update(elapsed:Float)
	{
		FlxG.watch.addQuick('Player location', getPosition());
		// this update function makes me wanna cry :/
		if (MovementEnabled)
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
			{
				acceleration.x = 0;
				velocity.x = 0;
				animation.play('idle');
			}

			if (FlxG.keys.anyJustPressed(jumpKeys) && isTouching(FlxObject.FLOOR))
				velocity.y = -PlayState.GRAVITY / 2;
		}

		// Dashin'
		if (FlxG.keys.anyJustPressed(dashKeys) && !dashCooldown && MovementEnabled) // i am aware of the "LongDash" thingy ok
		{
			MovementEnabled = false;
			isDashing = true;

			animation.play('slash', true);
			var dashSpeed = 2000;
			maxVelocity.x = dashSpeed;

			dashWait(0.5);

			FlxG.sound.play('assets/sounds/dash.wav');
			FlxG.camera.shake(0.01, 0.1);
			if (!flipX)
				velocity.x = dashSpeed;
			else
				velocity.x = -dashSpeed;
		}
		super.update(elapsed);

		FlxG.watch.addQuick('playerVelocity X', velocity.x);
		FlxG.watch.addQuick('Movement enabled', MovementEnabled);
		hitboxFix();

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
}
