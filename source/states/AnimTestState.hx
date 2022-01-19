package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import haxe.Json;
import lime.utils.Assets;

/*
 * Animation Debug Test (I'm proud of this :D).
 * This was made in a rush so pls cut me some slack D: (Making the code look nicer is on my to do list :P)
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

class AnimTestState extends FlxState
{
	var displayChar:FlxSprite;

	var charList:Array<String> = TextUtil.arrayifyTextFile('assets/data/charList.txt');
	var charDropdown:FlxUIDropDownMenu;
	var animInput:FlxInputText;
	var playAnimBTN:FlxButton;

	var loadHitboxBTN:FlxButton;
	var arrayHitboxChoice:FlxInputText;

	var moveSpeed:Int;
	var daBoxData:HitboxData;

	// DataLol
	var offsetDisplayText:FlxText;

	override public function create()
	{
		FlxG.sound.muteKeys = null; // >:(
		FlxG.debugger.drawDebug = true;
		FlxG.mouse.visible = true;

		var bg:FlxSprite = FlxGridOverlay.create(50, 50);
		add(bg);

		charDropdown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(charList, true));
		animInput = new FlxInputText(137, 10, 250, 'idle', 15, FlxColor.BLACK, FlxColor.WHITE);
		playAnimBTN = new FlxButton(400, 10, 'Play', playAnim);
		loadHitboxBTN = new FlxButton(1140, 697, 'Load HITBOX', updateDaHitbox);
		arrayHitboxChoice = new FlxInputText(1225, 696, 50, '0', 15, FlxColor.BLACK, FlxColor.WHITE);

		offsetDisplayText = new FlxText(0, 0, FlxG.width);
		offsetDisplayText.setFormat(null, 30, FlxColor.BLACK, FlxTextAlign.RIGHT);

		//-----[CHARACTER]-----\\
		displayChar = new FlxSprite();
		// displayChar.antialiasing = true;
		playAnim();
		FlxG.debugger.visible = false;
		displayChar.screenCenter();

		// Layering
		add(displayChar);

		add(charDropdown);
		add(animInput);
		add(playAnimBTN);
		add(offsetDisplayText);
		add(loadHitboxBTN);
		add(arrayHitboxChoice);

		super.create();
		displayChar.frames = sparrowFrames(charDropdown.selectedLabel);
	}

	override public function update(elapsed)
	{
		// This is a disaster lol
		super.update(elapsed);
		hitboxControl();
		charDrag();

		// Control basically
		if (!animInput.hasFocus && !arrayHitboxChoice.hasFocus)
		{
			if (FlxG.keys.justPressed.F)
				FlxG.fullscreen = !FlxG.fullscreen;

			if (FlxG.keys.justPressed.SPACE)
				playAnim(); // quick play :)

			if (FlxG.keys.justPressed.Q)
				FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;

			if (FlxG.keys.justPressed.ENTER)
				displayChar.screenCenter();

			if (FlxG.keys.justPressed.K)
				displayChar.flipX = !displayChar.flipX;
		}

		if (FlxG.keys.pressed.SHIFT)
			moveSpeed = 5;
		else
			moveSpeed = 1;

		// INFO TEXT
		offsetDisplayText.text = 'HITBOX DATA\nX: ' + displayChar.offset.x + '\nY:' + displayChar.offset.y + '\nHEIGHT:' + displayChar.height + '\nWIDTH:'
			+ displayChar.width;
	}

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

	function hitboxControl()
	{
		if (!animInput.hasFocus && !arrayHitboxChoice.hasFocus)
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
		}
	}

	function charDrag()
	{
		if (FlxG.mouse.overlaps(displayChar))
			if (FlxG.mouse.pressed)
				displayChar.setPosition(FlxG.mouse.getPosition().x - displayChar.width / 2, FlxG.mouse.getPosition().y - displayChar.height / 2);

		if (!animInput.hasFocus && !arrayHitboxChoice.hasFocus)
		{
			if (FlxG.keys.pressed.UP)
				displayChar.y -= moveSpeed;
			if (FlxG.keys.pressed.DOWN)
				displayChar.y += moveSpeed;
			if (FlxG.keys.pressed.LEFT)
				displayChar.x -= moveSpeed;
			if (FlxG.keys.pressed.RIGHT)
				displayChar.x += moveSpeed;
		}
	}

	function updateDaHitbox()
	{
		var dataFile = Assets.getText('assets/data/offsets/' + charDropdown.selectedLabel + '.OFFSET');
		daBoxData = Json.parse(dataFile)[Std.parseInt(arrayHitboxChoice.text)]; // make the 0 da choice of da user
		displayChar.offset.x = daBoxData.x;
		displayChar.offset.y = daBoxData.y;
		displayChar.width = daBoxData.width;
		displayChar.height = daBoxData.height;
		displayChar.scale.set(daBoxData.scale, daBoxData.scale);
	}

	function sparrowFrames(key:String)
	{
		return FlxAtlasFrames.fromSparrow('assets/images/$key.png', 'assets/images/$key.xml');
	}
}
