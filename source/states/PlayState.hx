package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;

class PlayState extends FlxState
{
	public static var GRAVITY = 1000;
	public static var LevelID:Int;
	// public static var hasDied:Bool;
	public static var fromLvSelect:Bool;

	var maxLevels:Int = Std.parseInt(Assets.getText('assets/data/levels/levels.txt'));
	var canTP:Bool;
	var exitDoorDebounce:Bool;

	var map:FlxOgmo3Loader;
	var level:FlxTilemap;
	var spikeGroup:FlxTypedGroup<Spike>;
	var lostSoulGroup:FlxTypedGroup<LostSoul>;

	var plrSpawnPos:Array<Float> = [0, 0];

	var player:Player;
	var tpEnter:FlxSprite;
	var tpExit:FlxSprite;
	var exitDoor:FlxSprite;
	var dialogEvent:FlxSprite;

	var GameCam:FlxCamera;
	var UIcam:FlxCamera;

	override public function create()
	{
		FlxTimer.globalManager.active = true;
		FlxG.watch.addQuick('LevelID', LevelID);
		canTP = true;
		exitDoorDebounce = false;

		GameCam = new FlxCamera();
		UIcam = new FlxCamera();

		FlxG.cameras.reset(GameCam);
		FlxG.cameras.add(UIcam);
		FlxCamera.defaultCameras = [GameCam];

		UIcam.bgColor.alpha = 0;

		player = new Player();
		spikeGroup = new FlxTypedGroup<Spike>();
		lostSoulGroup = new FlxTypedGroup<LostSoul>();

		exitDoor = new FlxSprite().loadGraphic('assets/images/ExitDoor.png');
		exitDoor.scale.set(0.3, 0.3);
		exitDoor.updateHitbox();
		exitDoor.width -= 20;
		exitDoor.offset.x = 110.1;

		//-----[MAP THINGS]-----\\
		map = new FlxOgmo3Loader('assets/data/levels/OVERLORDS.ogmo', 'assets/data/levels/$LevelID/Lv$LevelID.json');
		level = map.loadTilemap('assets/images/tileset.png', 'level');
		level.follow();

		level.setTileProperties(1, FlxObject.ANY);
		level.setTileProperties(2, FlxObject.NONE);
		//-------------------------\\
		// LAYERING
		var daBackDrop = new FlxBackdrop('assets/images/backdrop.png', 0.5, 0.5);
		daBackDrop.velocity.set(10, -10);
		add(daBackDrop);
		add(level);
		add(spikeGroup);
		add(lostSoulGroup);
		add(exitDoor);
		add(player);

		GameCam.follow(player, SCREEN_BY_SCREEN, 0.01);
		//----------------\\
		super.create(); // da super.create() :O
		//----------------\\
		map.loadEntities(placeDaEntities, "entities");

		// music haha
		if (FlxG.sound.music == null)
			FlxG.sound.playMusic("assets/music/Eric Skiff - Underclocked.wav");
		FlxG.sound.music.volume = 0.5;

		// other things

		GameCam.fade(FlxColor.BLACK, 0.5, true, function()
		{
			if (LevelID == 0 && !fromLvSelect)
			{
				Player.MovementEnabled = false;
			}
			else if (!NarratorSpeak.isInProgress)
				Player.MovementEnabled = true;
		});

		if (!fromLvSelect)
			levelEvents(); // like cutscenes or sum shit

		FlxG.debugger.visible = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(player, level);
		FlxG.collide(lostSoulGroup, level);

		if (FlxG.collide(player, lostSoulGroup, (a, c) -> // thank u Markl u da g
		{
			if (Player.isDashing)
			{
				lostSoulGroup.remove(c);
				FlxG.sound.play('assets/sounds/ouch.wav');
				FlxG.camera.shake(0.001, 0.1);
				camera.zoom = 1.05;
				FlxTween.tween(camera, {zoom: 1}, 0.5, {
					ease: FlxEase.circOut
				});
			}
			else
			{
				plrHit();
			}
		}))
			if (lostSoulGroup.length > 0)
			{
				// do none
			}

		if (FlxG.collide(player, spikeGroup))
			plrHit();

		//-----[TP PORTALS]-----\\
		if (FlxG.overlap(player, tpEnter) && canTP)
		{
			canTP = false;
			player.setPosition(tpExit.x, tpExit.y);
			FlxG.sound.play('assets/sounds/teleport.wav');
			new FlxTimer().start(3, function(tmr:FlxTimer) canTP = true);
		}

		if (FlxG.overlap(player, tpExit) && canTP)
		{
			canTP = false;
			player.setPosition(tpEnter.x, tpEnter.y);
			FlxG.sound.play('assets/sounds/teleport.wav');
			new FlxTimer().start(3, function(tmr:FlxTimer) canTP = true);
		}
		//-----[EXIT DOOR]-----\\
		if (FlxG.overlap(player, exitDoor))
		{
			if (!exitDoorDebounce)
			{
				exitDoorDebounce = true;
				if (LevelID++ > maxLevels)
				{
					if (!fromLvSelect)
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() FlxG.switchState(new GameCompleteState()));
					}
					else
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() FlxG.switchState(new LevelSelectState()));
					}
				}
				else
				{
					if (!fromLvSelect)
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() FlxG.resetState());
					}
					else
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.2, false, function() FlxG.switchState(new LevelSelectState()));
					}
				}
			}
		}
		//-----[DIALOG EVENT]-----\\
		if (FlxG.overlap(player, dialogEvent))
		{
			if (!fromLvSelect)
			{
				dialogEvent.kill();
				var daNewDialog:NarratorSpeak = new NarratorSpeak('dialog');
				daNewDialog.cameras = [UIcam];
				Player.MovementEnabled = false;
				player.velocity.x = 0;
				player.acceleration.x = 0;
				player.animation.play('idle');
				add(daNewDialog);
			}
		}
		#if debug
		if (FlxG.keys.justPressed.R)
		{
			plrHit();
		}
		#end

		if (FlxG.keys.anyJustPressed([ESCAPE]) && player.animation.curAnim.name != 'wake' && !NarratorSpeak.isInProgress)
			openSubState(new PauseSubState());
	}

	function placeDaEntities(epicEntity:EntityData)
	{
		var entX = epicEntity.x;
		var entY = epicEntity.y;

		switch (epicEntity.name.toLowerCase())
		{
			case 'playerspawn':
				player.setPosition(entX - player.width / 2, entY - player.height + 16);
				plrSpawnPos[0] = entX - player.width / 2;
				plrSpawnPos[1] = entY - player.height + 16;

			case 'spike':
				var spike:Spike = new Spike();
				switch (epicEntity.values.rotation) // bogdan from the past here, make sure u fix the hitboxes depending on the direction :)
				{
					case 'up':
						spike.angle = 0;
						spike.setPosition(entX, entY - spike.height + 16);
					case 'down':
						spike.angle = 180;
						spike.setPosition(entX, entY + spike.height - 32);
					case 'left':
						spike.angle = -90;
						spike.setPosition(entX - 32, entY);
					case 'right':
						spike.angle = 90;
						spike.setPosition(entX - 16, entY);
				}
				spikeGroup.add(spike);
			case 'tpenter':
				tpEnter = new FlxSprite();
				tpEnter.loadGraphic('assets/images/Portal.png');
				tpEnter.scale.set(1.6, 1.6);
				tpEnter.setPosition(entX - tpEnter.width / 2, entY + 16 - tpEnter.height);
				tpEnter.updateHitbox();
				tpEnter.width = 32;
				tpEnter.offset.x = 17;
				add(tpEnter);
				FlxG.watch.addQuick('TpEnter location', tpEnter.getPosition());
			case 'tpexit':
				tpExit = new FlxSprite();
				tpExit.loadGraphic('assets/images/Portal.png');
				tpExit.scale.set(1.6, 1.6);
				tpExit.setPosition(entX - tpEnter.width / 2, entY + 16 - tpEnter.height);
				tpExit.updateHitbox();
				tpExit.width = 32;
				tpExit.offset.x = 17;
				add(tpExit);
				FlxG.watch.addQuick('TpExit location', tpExit.getPosition());
			case 'lostsoul':
				var sadSoulNoooo:LostSoul = new LostSoul();
				sadSoulNoooo.setPosition(entX - sadSoulNoooo.width / 2, entY - sadSoulNoooo.height + 16);
				lostSoulGroup.add(sadSoulNoooo);
			case 'exitdoor':
				exitDoor.setPosition(entX - exitDoor.width / 2, entY - exitDoor.height + 16);
			case 'dialogevent':
				dialogEvent = new FlxSprite().makeGraphic(10, FlxG.height, FlxColor.GRAY);
				dialogEvent.updateHitbox();
				dialogEvent.alpha = 0;
				dialogEvent.setPosition(entX - dialogEvent.width / 2 + 16, entY - dialogEvent.height + 16);
				Player.MovementEnabled = false;
				add(dialogEvent);
		}
	}

	function plrHit()
	{
		player.setPosition(plrSpawnPos[0], plrSpawnPos[1]);
		Player.MovementEnabled = false;
		player.acceleration.x = 0;
		player.velocity.x = 0;
		player.flipX = false;
		FlxG.sound.play('assets/sounds/ouch.wav');
		FlxG.camera.shake(0.05, 0.1);
		camera.flash(FlxColor.RED, 0.5);
		player.animation.stop();
		player.animation.play('respawn', true);

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			Player.MovementEnabled = true; // this is so death animation can play :O
		});
	}

	function levelEvents()
	{
		switch (LevelID)
		{
			case 0:
				var daPopup:Popup = new Popup("Eric Skiff - Underclocked"); // this tune is a banger aaaaaAAAAAAAAA
				daPopup.cameras = [UIcam];
				add(daPopup);

				player.animation.play('wake', true);
				GameCam.zoom = 2;
				GameCam.y -= 100;
				// new FlxTimer().start(0.01, function(tmr:FlxTimer) FlxG.sound.play('assets/sounds/wakeUp.ogg', 0.5));
				FlxG.sound.play('assets/sounds/wakeUp.ogg', 0.5);

				FlxTween.tween(GameCam, {zoom: 1, y: 0}, 7, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						var watText:NarratorSpeak = new NarratorSpeak('Start');
						watText.cameras = [UIcam];
						add(watText);
					}
				});
			case 1:
				var watText:NarratorSpeak = new NarratorSpeak('Start');
				watText.cameras = [UIcam];
				watText.x += 90;
				watText.y -= 100;
				add(watText);
		}
	}
}
