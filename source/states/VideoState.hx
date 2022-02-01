package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;

class VideoState extends FlxState
{
	var videoName:String;
	var onVidDone:Void->Void;

	public function new(vidName:String, onComplete:Void->Void)
	{
		super();
		videoName = vidName;
		onVidDone = onComplete; // add webm support for this!!!
	}

	override public function create()
	{
		super.create();

		camera.bgColor = 0x000000;
		#if !html5
		// must be vp8 webm
		var webmPath = 'assets/videos/$videoName.webm';
		var autoPlay = false;
		var video = new FlxVideo(webmPath, autoPlay, function()
		{
			onVidDone();
		});
		video.screenCenter();
		add(video);

		video.play();
		var buttonsY = FlxG.height - 30;
		add(new FlxButton(10, buttonsY, "PLAY", () ->
		{
			video.play();
		}));

		// todo, after some edits to WebmPlayer?
		// add(new FlxButton(100, buttonsY, "STOP", () ->
		// {
		// 	video.stop();
		// }));

		add(new FlxButton(190, buttonsY, "RESTART", () ->
		{
			video.restart();
		}));
		#else
		FlxG.addChildBelowMouse(new Mp4Video(videoName, function()
		{
			onVidDone();
		}));
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
