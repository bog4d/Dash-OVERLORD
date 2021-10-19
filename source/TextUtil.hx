package;

import openfl.utils.Assets;

using StringTools;

class TextUtil
{
	public static function arrayifyTextFile(path:String):Array<String>
	{
		var daEpicArray:Array<String> = Assets.getText(path).trim().split("\n");

		for (i in 0...daEpicArray.length)
		{
			daEpicArray[i] = daEpicArray[i].trim();
		}

		return daEpicArray;
	}
}
