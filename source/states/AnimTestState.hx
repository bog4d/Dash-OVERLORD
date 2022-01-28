package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

/*
 * Developed by Bogdan2D.
 */
typedef HitboxData =
{
	x:Float,
	y:Float,
	width:Float,
	height:Float,
	scale:Float
}

//-----[PATH SETUP]-----\\
var path_charList:String = 'assets/data/charList.txt';
var path_offset:String = 'assets/data/offsets';
var path_charFolder:String = 'assets/images';

//-----------------------\\

class AnimTestState extends FlxState
{
	var displayChar:FlxSprite;
	var displayHitbox:FlxSprite;

	var charList:Array<String> = arrayifyTextFile(path_charList);
	var charDropdown:FlxUIDropDownMenu;
	var animInput:FlxInputText;
	var playAnimBTN:FlxButton;

	var loadHitboxBTN:FlxButton;
	var arrayHitboxChoice:FlxUINumericStepper;

	var antialiasingEnabled:FlxUICheckBox;

	var moveSpeed:Int;
	var daBoxData:HitboxData;

	// DataLol
	var offsetDisplayText:FlxText;
	// Cameras
	var prevCam:FlxCamera;
	var uiCam:FlxCamera;

	var bg:FlxSprite;

	function playAnim()
	{
		switch (charDropdown.selectedLabel)
		{
			case 'player':
				if (displayChar.frames != sparrowFrames(charDropdown.selectedLabel))
					displayChar.frames = sparrowFrames(charDropdown.selectedLabel);
				displayChar.animation.addByPrefix('idle', 'idle', 24, true);
				displayChar.animation.addByPrefix('walk', 'walk', 24, true);
				displayChar.animation.addByPrefix('respawn', 'respawn ouch', 24, false);
				displayChar.animation.addByPrefix('slash', 'slash', 30, false);
				displayChar.animation.addByPrefix('wake', 'wake up', 24, false);
				displayChar.animation.play(animInput.text, true);
			case 'lostSoul':
				if (displayChar.frames != sparrowFrames(charDropdown.selectedLabel))
					displayChar.frames = sparrowFrames(charDropdown.selectedLabel);

				displayChar.animation.addByPrefix('idle', 'idle', 24, true);
				displayChar.animation.addByPrefix('walk', 'walk', 24, true);
				displayChar.animation.play(animInput.text, true);
		}
	}

	override public function create()
	{
		FlxG.resizeWindow(1280, 720);
		FlxG.fixedTimestep = false; // If you want things like replays in yo game make sure to delete this line.
		// FlxG.sound.muteKeys = null; // >:(
		// FlxG.debugger.drawDebug = true;
		FlxG.mouse.visible = true;

		//-----[Camera crap]-----\\
		prevCam = new FlxCamera();
		uiCam = new FlxCamera();

		FlxG.cameras.reset(prevCam);
		FlxG.cameras.add(uiCam);
		FlxCamera.defaultCameras = [prevCam];

		uiCam.bgColor.alpha = 0;

		bg = FlxGridOverlay.create(48, 48);
		bg.scrollFactor.set(0, 0);
		add(bg);
		// var repatShit:FlxBackdrop = new FlxBackdrop(bg, 1, 1);

		charDropdown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(charList, true));
		animInput = new FlxInputText(137, 10, 250, 'idle', 15, FlxColor.BLACK, FlxColor.WHITE);
		playAnimBTN = new FlxButton(400, 10, 'Play', playAnim);
		loadHitboxBTN = new FlxButton(1137, 697, 'Load HITBOX', updateDaHitbox);
		arrayHitboxChoice = new FlxUINumericStepper(1220, 700, 1, 0, 0);
		antialiasingEnabled = new FlxUICheckBox(10, 700, null, null, "Antialiasing", 100, function() displayChar.antialiasing = antialiasingEnabled.checked);
		antialiasingEnabled.textY -= 3;

		offsetDisplayText = new FlxText(0, 0, FlxG.width);
		offsetDisplayText.setFormat(null, 30, FlxColor.BLACK, FlxTextAlign.RIGHT);

		displayHitbox = new FlxSprite();
		displayHitbox.makeGraphic(10, 10, FlxColor.RED);
		displayHitbox.alpha = 0.5;

		//-----[CHARACTER]-----\\
		displayChar = new FlxSprite();
		playAnim();
		FlxG.debugger.visible = false;
		displayChar.screenCenter();

		// Layering
		add(displayChar);
		add(displayHitbox);

		// UI
		add(charDropdown);
		charDropdown.cameras = [uiCam];
		add(animInput);
		animInput.cameras = [uiCam];
		add(playAnimBTN);
		playAnimBTN.cameras = [uiCam];
		add(offsetDisplayText);
		offsetDisplayText.cameras = [uiCam];
		add(loadHitboxBTN);
		loadHitboxBTN.cameras = [uiCam];
		add(arrayHitboxChoice);
		arrayHitboxChoice.cameras = [uiCam];
		add(antialiasingEnabled);
		antialiasingEnabled.cameras = [uiCam];

		//-------------\\
		super.create();
		prevCam.bgColor = FlxColor.BLACK;
		//-------------\\
		displayChar.frames = sparrowFrames(charDropdown.selectedLabel);

		var HelpText:FlxText = new FlxText(10, 660, FlxG.width, "Press F1 for help.");
		HelpText.setFormat(null, 30, FlxColor.BLACK, LEFT);
		add(HelpText);
		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			FlxTween.tween(HelpText, {alpha: 0}, 1, {
				onComplete: function(twn:FlxTween)
				{
					remove(HelpText);
				}
			});
		});
	}

	override public function update(elapsed)
	{
		// This is a disaster lol
		super.update(elapsed);
		hitboxControl();
		charDrag();

		if (!animInput.hasFocus)
		{
			if (FlxG.keys.justPressed.F)
				FlxG.fullscreen = !FlxG.fullscreen;

			if (FlxG.keys.justPressed.SPACE)
				playAnim(); // quick play :)

			if (FlxG.keys.justPressed.Q)
				displayHitbox.visible = !displayHitbox.visible;
			// FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;

			if (FlxG.keys.justPressed.ENTER)
				displayChar.screenCenter();

			if (FlxG.keys.justPressed.K)
				displayChar.flipX = !displayChar.flipX;

			if (FlxG.keys.justPressed.R)
				displayChar.updateHitbox();

			if (FlxG.keys.justPressed.F1)
				FlxG.openURL('https://github.com/Bogdan2D/FlixelSparrowAnimationDebug/wiki/3.-How-to-use.');

			// CAMERA MOVEMENT
			if (FlxG.keys.pressed.X)
				prevCam.zoom += 0.05;

			if (FlxG.keys.pressed.Z && prevCam.zoom > 1)
				prevCam.zoom -= 0.05;
		}

		if (FlxG.keys.pressed.SHIFT)
			moveSpeed = 5;
		else
			moveSpeed = 1;

		if (FlxG.keys.justPressed.NINE)
		{
			if (bg.alpha == 1)
				bg.alpha = 0.5;
			else
				bg.alpha = 1;
		}
		displayHitbox.setPosition(displayChar.x, displayChar.y);
		displayHitbox.makeGraphic(Std.parseInt('' + displayChar.width), Std.parseInt('' + displayChar.height), FlxColor.RED);
		// ^^ lol this thing actually worked :)))
		displayHitbox.updateHitbox();

		// INFO TEXT
		offsetDisplayText.text = 'HITBOX DATA\nX: ' + displayChar.offset.x + '\nY:' + displayChar.offset.y + '\nHEIGHT:' + displayChar.height + '\nWIDTH:'
			+ displayChar.width + '\n SPRITE SCALE\n' + displayChar.scale.x;
	}

	function hitboxControl()
	{
		if (!animInput.hasFocus)
		{
			if (moveSpeed < 2)
			{
				if (FlxG.keys.justPressed.D)
					displayChar.offset.x += moveSpeed;
				if (FlxG.keys.justPressed.A)
					displayChar.offset.x -= moveSpeed;
				if (FlxG.keys.justPressed.W)
					displayChar.offset.y -= moveSpeed;
				if (FlxG.keys.justPressed.S)
					displayChar.offset.y += moveSpeed;
			}
			else
			{
				if (FlxG.keys.justPressed.D)
					displayChar.width += 1;
				if (FlxG.keys.justPressed.A)
					displayChar.width -= 1;
				if (FlxG.keys.justPressed.W)
					displayChar.height -= 1;
				if (FlxG.keys.justPressed.S)
					displayChar.height += 1;
			}
			if (FlxG.keys.justPressed.P)
			{
				if (moveSpeed == 1)
					displayChar.scale.add(0.01, 0.01);
				else
					displayChar.scale.add(0.1, 0.1);
			}
			if (FlxG.keys.justPressed.O)
			{
				if (moveSpeed == 1)
					displayChar.scale.add(-0.01, -0.01);
				else
					displayChar.scale.add(-0.1, -0.1);
			}
		}
	}

	function charDrag()
	{
		if (FlxG.mouse.overlaps(displayChar))
			if (FlxG.mouse.pressed)
				displayChar.setPosition(FlxG.mouse.getPosition().x - displayChar.width / 2, FlxG.mouse.getPosition().y - displayChar.height / 2);

		if (FlxG.keys.pressed.UP)
			displayChar.y -= moveSpeed;
		if (FlxG.keys.pressed.DOWN)
			displayChar.y += moveSpeed;
		if (FlxG.keys.pressed.LEFT)
			displayChar.x -= moveSpeed;
		if (FlxG.keys.pressed.RIGHT)
			displayChar.x += moveSpeed;
	}

	function updateDaHitbox()
	{
		var dataFile = Assets.getText('$path_offset/' + charDropdown.selectedLabel + '.json');
		daBoxData = Json.parse(dataFile)[Std.parseInt(Std.string(arrayHitboxChoice.value))];
		displayChar.offset.x = daBoxData.x;
		displayChar.offset.y = daBoxData.y;
		displayChar.width = daBoxData.width;
		displayChar.height = daBoxData.height;
		displayChar.scale.set(daBoxData.scale, daBoxData.scale);
	}

	function sparrowFrames(key:String)
		return FlxAtlasFrames.fromSparrow('$path_charFolder/$key.png', '$path_charFolder/$key.xml');

	public static function arrayifyTextFile(path):Array<String>
	{
		var daArray:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daArray.length)
		{
			daArray[i] = daArray[i].trim();
		}
		return daArray;
	}
}
