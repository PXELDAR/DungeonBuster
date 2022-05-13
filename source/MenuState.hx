package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	// ============================================================================================
	private var _title:FlxText;

	private var _exitButtonXPos:Int = FlxG.width - 28;
	private var _exitButtonYPos:Int = 8;
	private var _exitButtonSize:Int = 20;

	private var _cameraTransitionTime:Float = 0.66;

	private var _playText:String = "Play";
	private var _titleText:String = "Dungeon Buster";
	private var _optionsText:String = "Options";
	private var _exitText:String = "X";

	private var _playButton:FlxButton;
	private var _optionsButton:FlxButton;

	#if desktop
	private var _exitButton:FlxButton;
	#end

	// ============================================================================================

	override public function create()
	{
		// Don't restart the music if it's already playing
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(AssetPaths.gamemusic__ogg, 1, true);
		}

		_title = new FlxText(20, 0, 0, _titleText, 22);
		_title.alignment = CENTER;
		_title.screenCenter();
		add(_title);

		_playButton = new FlxButton(0, 0, _playText, onClickPlay);
		_playButton.x = (FlxG.width / 2) - _playButton.width - 10;
		_playButton.y = FlxG.height - _playButton.height - 10;
		add(_playButton);
		_playButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);

		_optionsButton = new FlxButton(0, 0, _optionsText, onClickOptions);
		_optionsButton.x = (FlxG.width / 2) + 10;
		_optionsButton.y = FlxG.height - _optionsButton.height - 10;
		add(_optionsButton);
		_optionsButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);

		#if desktop
		_exitButton = new FlxButton(_exitButtonXPos, _exitButtonYPos, _exitText, onClickExit);
		_exitButton.loadGraphic(AssetPaths.button__png, true, _exitButtonSize, _exitButtonSize);
		add(_exitButton);
		#end

		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, true);

		super.create();
	}

	// ============================================================================================

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// ============================================================================================

	private function onClickPlay()
	{
		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, false, function()
		{
			FlxG.switchState(new PlayState());
		});
	}

	// ============================================================================================

	private function onClickOptions()
	{
		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, false, function()
		{
			FlxG.switchState(new OptionsState());
		});
	}

	// ============================================================================================
	#if desktop
	private function onClickExit()
	{
		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, false, function()
		{
			Sys.exit(0);
		});
	}
	#end
	// ============================================================================================
}
