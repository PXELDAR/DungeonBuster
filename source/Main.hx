package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	// ============================================================================================
	private var _saveKey:String = "_gameSave";

	private var _gameScreenWidth:Int = 320;
	private var _gameScreenHeight:Int = 240;

	// ============================================================================================

	public function new()
	{
		super();

		addChild(new FlxGame(_gameScreenWidth, _gameScreenHeight, MenuState));

		var save = new FlxSave();
		save.bind(_saveKey);

		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}

		save.close();
	}

	// ============================================================================================
}
