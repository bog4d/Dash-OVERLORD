package;

import flixel.FlxG;
import flixel.FlxState;
import haxe.Constraints.Function;
import motion.Actuate;
import openfl.display.Sprite;
import openfl.events.AsyncErrorEvent;
import openfl.events.MouseEvent;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;

class Mp4Video extends Sprite
{
	private var netStream:NetStream;
	private var overlay:Sprite;
	private var video:Video;

	var onVidDone:Void->Void;

	public function new(vidName:String, onVidComplete:Void->Void)
	{
		super();

		onVidDone = onVidComplete;

		video = new Video();
		addChild(video);

		var netConnection = new NetConnection();
		netConnection.connect(null);

		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: client_onMetaData};
		netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStream_onAsyncError);

		#if (js && html5)
		overlay = new Sprite();
		// overlay.graphics.beginFill(0, 0.5);
		// overlay.graphics.drawRect(0, 0, 560, 320);
		// overlay.addEventListener(MouseEvent.MOUSE_DOWN, overlay_onMouseDown);
		overlay.buttonMode = true;
		addChild(overlay);

		netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnection_onNetStatus);
		#else
		netStream.play('assets/videos/$vidName.mp4');
		#end

		Actuate.tween(overlay, 2, {alpha: 0});
		netStream.play('assets/videos/$vidName.mp4');
	}

	private function client_onMetaData(metaData:Dynamic)
	{
		video.attachNetStream(netStream);

		video.width = video.videoWidth;
		video.height = video.videoHeight;
	}

	private function netStream_onAsyncError(event:AsyncErrorEvent):Void
	{
		trace("Error loading video");
	}

	function netConnection_onNetStatus(event:NetStatusEvent):Void
	{
		if (event.info.code == "NetStream.Play.Complete")
		{
			Actuate.tween(overlay, 1, {alpha: 1});
			video.alpha = 0;
			onVidDone();
			// FlxG.switchState(new MainMenuState());
		}
	}
	/*
		private function overlay_onMouseDown(event:MouseEvent):Void
		{
			Actuate.tween(overlay, 2, {alpha: 0});
			netStream.play("assets/videos/flipLeak.mp4");
		}
	 */
}
