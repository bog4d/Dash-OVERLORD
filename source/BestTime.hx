package;

import flixel.math.FlxMath;
import flixel.util.FlxSave;

class BestTime
{
	public static var bestTimes:Map<Int, Float> = new Map();
	public static var _gameSave:FlxSave = new FlxSave();

	public static function setNewTime(LevelID:Int)
	{
		bestTimes.set(LevelID, FlxMath.roundDecimal(PlayState.stopwatch.elapsedTime, 2));
		saveBestTime(LevelID);
	}

	public static function getLevelTime(LevelID:Int):Float
	{
		if (bestTimes[LevelID] == null)
			bestTimes[LevelID] = 999;
		return bestTimes[LevelID];
	}

	public static function saveBestTime(LevelID:Int)
	{
		_gameSave.bind('GameSave');
		_gameSave.data.bestTimes[LevelID] = bestTimes[LevelID];
		_gameSave.flush();
	}

	public static function resetAllTimes()
	{
		_gameSave.bind('GameSave');
		_gameSave.data.bestTimes = null;
		_gameSave.flush();
	}
}
