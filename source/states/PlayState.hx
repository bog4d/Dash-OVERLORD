package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	public static var GRAVITY = 1000;
	public static var LevelID:Int;
	public static var stopwatch:FlxTimer;
	// public static var hasDied:Bool;
	public static var fromLvSelect:Bool;

	var maxLevels:Int = Std.parseInt(TextUtil.arrayifyTextFile('assets/data/levels/levelData.txt')[0]);
	var canTP:Bool;
	var exitDoorDebounce:Bool;

	var map:FlxOgmo3Loader;
	var level:FlxTilemap;
	var spikeGroup:FlxTypedGroup<Spike>;
	var lostSoulGroup:FlxTypedGroup<LostSoul>;
	var jumpPadGroup:FlxTypedGroup<JumpPad>;

	var plrSpawnPos:Array<Float> = [0, 0];

	var player:Player;
	var plrDashTrail:FlxTrail;
	var tpEnter:FlxSprite;
	var tpExit:FlxSprite;
	var exitDoor:FlxSprite;
	var dialogEvent:FlxSprite;
	var endLevelAnimationTrigger:FlxSprite;

	// cutscene sprites
	var hitSprite:FlxSprite;

	var GameCam:FlxCamera;
	var UIcam:FlxCamera;
	var hud:HUD;

	public static var isMedalLocked:Bool;
	public static var deaths:Int;

	var _settingsSave:FlxSave;
	var _gameSave:FlxSave;

	override public function create()
	{
		//-----[IMPORTANT STUFF]-----\\
		_settingsSave = new FlxSave();
		_settingsSave.bind('Settings');

		_gameSave = new FlxSave();
		_gameSave.bind('GameSave');

		FlxG.fixedTimestep = false;
		FlxTimer.globalManager.active = true;
		FlxG.watch.addQuick('LevelID', LevelID);
		canTP = true;
		exitDoorDebounce = false;
		stopwatch = new FlxTimer();
		//-----[CAMERA STUFF]-----\\
		GameCam = new FlxCamera();
		UIcam = new FlxCamera();

		FlxG.cameras.reset(GameCam);
		FlxG.cameras.add(UIcam);
		FlxCamera.defaultCameras = [GameCam];

		UIcam.bgColor.alpha = 0;
		hud = new HUD();
		hud.cameras = [UIcam];

		GameCam.antialiasing = _settingsSave.data.settings[2];
		UIcam.antialiasing = _settingsSave.data.settings[2];

		//-----[ENTITIES]-----\\
		player = new Player();
		plrDashTrail = new FlxTrail(player);
		spikeGroup = new FlxTypedGroup<Spike>();
		lostSoulGroup = new FlxTypedGroup<LostSoul>();
		jumpPadGroup = new FlxTypedGroup<JumpPad>();

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
		level.setTileProperties(3, FlxObject.ANY);
		level.setTileProperties(4, FlxObject.ANY);
		level.setTileProperties(5, FlxObject.ANY);
		level.setTileProperties(6, FlxObject.ANY);
		//-----[LAYERING]-----\\
		var daBackDrop = new FlxBackdrop('assets/images/backdrop.png', 0.5, 0.5);
		var frontClouds = new FlxBackdrop('assets/images/CloudThing.png', 1.5, 1.5);
		frontClouds.velocity.set(5, 0);
		frontClouds.useScaleHack = false;

		if (LevelID >= 20)
			daBackDrop.loadGraphic('assets/images/backdrop2.png');

		daBackDrop.velocity.set(10, -10);
		add(daBackDrop);

		//--------\\
		if (LevelID == 9)
		{
			hitSprite = new FlxSprite();
			hitSprite.frames = FlxAtlasFrames.fromSparrow('assets/images/spikeHit.png', 'assets/images/spikeHit.xml');
			hitSprite.animation.addByPrefix('die?', 'hit', 24, false);
			add(hitSprite);
		}
		//---------\\
		add(level);
		add(spikeGroup);
		add(lostSoulGroup);
		add(jumpPadGroup);
		add(exitDoor);
		add(plrDashTrail);
		add(player);
		add(frontClouds);
		// ui
		add(hud);
		GameCam.follow(player, _settingsSave.data.settings[0], 0.01);
		//----------------\\
		super.create(); // da super.create() :O
		if (!fromLvSelect)
		{
			_gameSave.data.curLevel = LevelID;
			_gameSave.flush();
		}
		stopwatch.reset();
		stopwatch.start(999);
		stopwatch.active = true;
		//----------------\\
		map.loadEntities(placeDaEntities, "entities");
		GameCam.scroll.set(player.x - FlxG.width / 2, player.y - FlxG.width / 2);

		// music haha
		if (FlxG.sound.music == null && _settingsSave.data.settings[1] == true)
		{
			FlxG.sound.playMusic("assets/music/Eric Skiff - Underclocked.wav");
			FlxG.sound.music.volume = 0.5;
		}

		// other things

		GameCam.fade(FlxColor.BLACK, 0.5, true, function()
		{
			if (LevelID == 0 && !fromLvSelect)
			{
				Player.MovementEnabled = false;
			}
			else if (!NarratorSpeak.isInProgress)
				Player.MovementEnabled = true;

			if (LevelID == 9)
				hitSprite.visible = false;
		});

		if (!fromLvSelect)
			levelEvents(); // like cutscenes or sum shit

		FlxG.debugger.visible = false;

		// Medal unlock (CAN ONLY BE UNLOCKED FROM STORY MODE aka NOT FROM LEVEL SELECT)
		if (!fromLvSelect)
		{
			switch (LevelID)
			{
				case 1:
					NGio.unlockMedal(65926); // Finished da tutorial
					checkIfLocked(65926, "Gettin' the hang of it!", "Complete the tutorial.");
				case 2:
					NGio.unlockMedal(65907); // Finished Level 1
					checkIfLocked(65907, "Lost soul?", "Beat Level 1");
			}
		}
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

		for (pad in jumpPadGroup)
		{
			if (FlxG.overlap(player, pad) && !pad.cooldown)
			{
				pad.cooldown = true;
				player.velocity.y = -pad.launchForce;
				FlxG.sound.play('assets/sounds/padJump.wav');
				FlxG.camera.shake(0.01, 0.1);
				FlxG.sound.play('assets/sounds/padShake.wav');
				player.scale.set(0.2, 0.4);

				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					pad.cooldown = false;
				});
			}
		}

		if (Player.isDashing)
			plrDashTrail.visible = true;
		else
			plrDashTrail.visible = false;

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
				stopwatch.cancel();
				hud.stopwatchText.color = 0xFF0000;

				if (stopwatch.elapsedTime < BestTime.getLevelTime(LevelID))
					BestTime.setNewTime(LevelID);

				if (LevelID + 1 > maxLevels)
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
						LevelID++;
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
				add(daNewDialog);
				player.animation.stop();
				player.animation.play('idle');
			}
		}

		//-----[DIALOG EVENT]-----\\
		if (FlxG.overlap(player, endLevelAnimationTrigger))
		{
			if (!fromLvSelect)
			{
				stopwatch.active = false;
				endLevelAnimationTrigger.kill();
				endLvAnimCutsceneTriggerHit();
			}
		}

		#if debug
		if (FlxG.keys.justPressed.R)
			plrHit();

		if (FlxG.keys.justPressed.N)
			Player.MovementEnabled = true;

		if (FlxG.keys.justPressed.G)
			player.setPosition(exitDoor.x, exitDoor.y);
		#end

		if (FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]) && !NarratorSpeak.isInProgress && Player.MovementEnabled)
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
				spike.scale.set(0.48, 0.48);
				spike.updateHitbox();
				switch (epicEntity.values.rotation) // bogdan from the past here, make sure u fix the hitboxes depending on the direction :)
				{
					case 'up':
						spike.angle = 0;
						spike.setPosition(entX, entY - spike.height + 16);
						spike.width -= spike.width / 2;
						spike.offset.x += spike.width / 2;
						spike.x += spike.width / 2;
					case 'down':
						spike.angle = 180;
						spike.setPosition(entX, entY + spike.height - 32);
						spike.width -= spike.width / 2;
						spike.offset.x += spike.width / 2;
						spike.x += spike.width / 2;
					case 'left':
						spike.angle = -90;
						spike.setPosition(entX - 32, entY);
						spike.width = spike.width / 2;
						spike.offset.x += 25;
						spike.x += 25.5;
					case 'right':
						spike.angle = 90;
						spike.setPosition(entX - 16, entY);
						spike.width = spike.width / 2 + 10;
				}
				spikeGroup.add(spike);

			case 'jumppad':
				var _jumpPad:JumpPad = new JumpPad();
				_jumpPad.launchForce = epicEntity.values.launchForce;
				_jumpPad.setPosition(entX - _jumpPad.width / 2, entY - _jumpPad.height + 16);
				jumpPadGroup.add(_jumpPad);
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
			case 'endlevelanimationcutscene':
				if (!fromLvSelect)
				{
					endLevelAnimationTrigger = new FlxSprite(entX, entY + 16);
					endLevelAnimationTrigger.makeGraphic(15, epicEntity.values.ObjectHeight, FlxColor.TRANSPARENT);
					endLevelAnimationTrigger.y -= endLevelAnimationTrigger.height;
					endLevelAnimationTrigger.ID = epicEntity.values.CutsceneID;
					add(endLevelAnimationTrigger);
				}
		}
	}

	function plrHit()
	{
		deaths++;
		FlxG.watch.addQuick('Deaths', deaths);
		player.setPosition(plrSpawnPos[0], plrSpawnPos[1]);
		Player.MovementEnabled = false;
		player.animation.stop();
		player.fsm.activeState = player.hit;
		FlxG.sound.play('assets/sounds/ouch.wav');
		FlxG.camera.shake(0.05, 0.1);
		camera.flash(FlxColor.RED, 0.5);

		GameCam.scroll.set(player.x - FlxG.width / 2, player.y - FlxG.width / 2);
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
				stopwatch.active = false;
				player.screenCenter(X);
				var daPopup:Popup = new Popup("Eric Skiff - Underclocked"); // this tune is a banger aaaaaAAAAAAAAA
				daPopup.cameras = [UIcam];
				if (_settingsSave.data.settings[1] == true)
					add(daPopup);

				player.animation.play('wake', true);
				GameCam.zoom = 2;

				FlxG.sound.play('assets/sounds/wakeUp.ogg', 0.5);

				FlxTween.tween(GameCam, {zoom: 1}, 7, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						Player.MovementEnabled = true;
						stopwatch.active = true;
						/*
							var watText:NarratorSpeak = new NarratorSpeak('Start');
							watText.cameras = [UIcam];
							add(watText);
						 */
					}
				});
			case 1:
				var watText:NarratorSpeak = new NarratorSpeak('Start');
				watText.cameras = [UIcam];
				watText.x += 90;
				watText.y -= 100;
				add(watText);
			case 9:
				var watText:NarratorSpeak = new NarratorSpeak('Start');
				watText.cameras = [UIcam];
				watText.x += 400;
				watText.y -= 20;
				add(watText);
		}
	}

	function endLvAnimCutsceneTriggerHit()
	{
		player.kill();
		Player.MovementEnabled = false;
		GameCam.follow(hitSprite, PLATFORMER, 0.17);
		GameCam.targetOffset.y = -200;
		switch (endLevelAnimationTrigger.ID)
		{
			case 1:
				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(2, 0);

				FlxG.sound.play('assets/sounds/EarRinging.ogg');
				hud._vignette.color = 0xFF0000;
				GameCam.shake(0.01, 0.1);
				FlxG.sound.play('assets/sounds/ouch.wav');
				hitSprite.visible = true;
				hitSprite.scale.set(0.3, 0.3);
				hitSprite.updateHitbox();
				hitSprite.setPosition(endLevelAnimationTrigger.x
					- endLevelAnimationTrigger.width / 2
					- 30,
					endLevelAnimationTrigger.y
					+ endLevelAnimationTrigger.height
					- 120);
				hitSprite.animation.play('die?');

				FlxTween.tween(GameCam, {zoom: 1.5}, 0.5, {
					ease: FlxEase.circOut,
					onComplete: function(twn:FlxTween) hud._vignette.color = 0xFF0000
				});

				hitSprite.animation.finishCallback = function(a:String)
				{
					FlxTween.tween(GameCam, {zoom: 1.7}, 5, {
						ease: FlxEase.sineIn,
					});

					GameCam.fade(0x000000, 5, false, function()
					{
						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							FlxG.switchState(new VideoState('act2', function()
							{
								LevelID++;
								FlxG.switchState(new PlayState());
								FlxG.log.notice('Begin ACT2');
							}));
						});
					});
				}
		}
	}

	function checkIfLocked(id:Int, medName:String, medDesc:String)
	{
		if (isMedalLocked)
		{
			var popup:MedalPopup = new MedalPopup(id, medName, medDesc);
			popup.cameras = [UIcam];
			add(popup);
		}
	}
}
