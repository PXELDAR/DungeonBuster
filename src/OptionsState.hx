package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class OptionsState extends FlxState
{
	// ============================================================================================
	#if desktop
	private var fullscreenButton:FlxButton;
	#end

	private var _titleField:FlxText;
	private var _volumeBar:FlxBar;
	private var _volumeField:FlxText;
	private var _volumeAmountField:FlxText;
	private var _volumeDownButton:FlxButton;
	private var _volumeUpButton:FlxButton;
	private var _clearDataButton:FlxButton;
	private var _backButton:FlxButton;

	private var _save:FlxSave;

	private var _optionTextYPos:Int = 20;
	private var _optionTextSize:Int = 22;
	private var _volumeTextSize:Int = 8;
	private var _volumeFieldYPos:Int = 10;
	private var _volumeDownButtonXPos:Int = 8;
	private var _volumeDownButtonPos:Int = 2;
	private var _volumeButtonsSize:Int = 20;
	private var _volumeUpButtonXPos:Int = FlxG.width - 28;
	private var _volumeAmountFieldWidth:Int = 200;
	private var _volumeAmountFieldSize:Int = 8;
	private var _fullScreenButtonYPos:Int = 8;
	private var _clearDataButtonXPos:Float = (FlxG.width / 2) - 90;
	private var _clearDataButtonYPos:Int = FlxG.height - 28;
	private var _backButtonXPos:Float = (FlxG.width / 2) + 10;
	private var _backButtonYPos:Int = FlxG.height - 28;
	private var _cameraTransitionTime:Float = 0.33;

	private var _optionsText:String = "Options";
	private var _volumeText:String = "Volume";
	private var _minusText:String = "-";
	private var _plusText:String = "+";
	private var _volumeKey:String = "volume";
	private var _percentageText:String = "%";
	private var _volumeAmountFieldColor:String = "0xff464646";
	private var _fullScreenText = "FULLSCREEN";
	private var _windowedText = "WINDOWED";
	private var _clearDataText = "Clear Data";
	private var _backText = "Back";

	// ============================================================================================

	override public function create():Void
	{
		_titleField = new FlxText(0, _optionTextYPos, 0, _optionsText, _optionTextSize);
		_titleField.alignment = CENTER;
		_titleField.screenCenter(FlxAxes.X);
		add(_titleField);

		_volumeField = new FlxText(0, _titleField.y + _titleField.height + _volumeFieldYPos, 0, _volumeText, _volumeTextSize);
		_volumeField.alignment = CENTER;
		_volumeField.screenCenter(FlxAxes.X);
		add(_volumeField);

		_volumeDownButton = new FlxButton(_volumeDownButtonXPos, _volumeField.y + _volumeField.height + _volumeDownButtonPos, _minusText, onClickVolumeDown);
		_volumeDownButton.loadGraphic(AssetPaths.button__png, true, _volumeButtonsSize, _volumeButtonsSize);
		_volumeDownButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_volumeDownButton);

		_volumeUpButton = new FlxButton(_volumeUpButtonXPos, _volumeDownButton.y, _plusText, onClickVolumeUp);
		_volumeUpButton.loadGraphic(AssetPaths.button__png, true, _volumeButtonsSize, _volumeButtonsSize);
		_volumeUpButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_volumeUpButton);

		_volumeBar = new FlxBar(_volumeDownButton.x + _volumeDownButton.width + 4, _volumeDownButton.y, LEFT_TO_RIGHT, Std.int(FlxG.width - 64),
			Std.int(_volumeUpButton.height));
		_volumeBar.createFilledBar(FlxColor.GRAY, FlxColor.WHITE, true, FlxColor.WHITE);
		add(_volumeBar);

		_volumeAmountField = new FlxText(0, 0, _volumeAmountFieldWidth, (FlxG.sound.volume * 100) + _percentageText, _volumeAmountFieldSize);
		_volumeAmountField.alignment = CENTER;
		_volumeAmountField.borderStyle = FlxTextBorderStyle.OUTLINE;
		_volumeAmountField.borderColor = 0xff464646;
		_volumeAmountField.y = _volumeBar.y + (_volumeBar.height / 2) - (_volumeAmountField.height / 2);
		_volumeAmountField.screenCenter(FlxAxes.X);
		add(_volumeAmountField);

		#if desktop
		fullscreenButton = new FlxButton(0, _volumeBar.y + _volumeBar.height + _fullScreenButtonYPos, FlxG.fullscreen ? _fullScreenText : _windowedText,
			clickFullscreen);
		fullscreenButton.screenCenter(FlxAxes.X);
		add(fullscreenButton);
		#end

		_clearDataButton = new FlxButton(_clearDataButtonXPos, _clearDataButtonYPos, _clearDataText, onClickClearData);
		_clearDataButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_clearDataButton);

		_backButton = new FlxButton(_backButtonXPos, _backButtonYPos, _backText, onClickBack);
		_backButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_backButton);

		_save = new FlxSave();
		_save.bind(_volumeKey);

		updateVolume();

		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, true);

		super.create();
	}

	// ============================================================================================
	#if desktop
	private function clickFullscreen()
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		fullscreenButton.text = FlxG.fullscreen ? _fullScreenText : _windowedText;
		_save.data.fullscreen = FlxG.fullscreen;
	}
	#end

	// ============================================================================================

	private function onClickClearData()
	{
		_save.erase();
		FlxG.sound.volume = 0.5;
		updateVolume();
	}

	// ============================================================================================

	private function onClickBack()
	{
		_save.close();
		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}

	// ============================================================================================

	private function onClickVolumeDown()
	{
		FlxG.sound.volume -= 0.1;
		_save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	// ============================================================================================

	private function onClickVolumeUp()
	{
		FlxG.sound.volume += 0.1;
		_save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	// ============================================================================================

	private function updateVolume()
	{
		var volume:Int = Math.round(FlxG.sound.volume * 100);
		_volumeBar.value = volume;
		_volumeAmountField.text = volume + _percentageText;
	}

	// ============================================================================================
}
