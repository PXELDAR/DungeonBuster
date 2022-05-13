package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

class GameOverState extends FlxState
{
	// ============================================================================================
	private var _scoreIcon:FlxSprite;

	private var _mainMenuButton:FlxButton;

	private var _titleField:FlxText;
	private var _finalScoreField:FlxText;
	private var _scoreField:FlxText;
	private var _highScoreField:FlxText;

	private var _win:Bool;

	private var _score:Int = 0;
	private var _titleTextSize:Int = 22;
	private var _finalScoreSize:Int = 8;
	private var _scoreTextSize:Int = 8;
	private var _titleTextYPos:Int = 20;
	private var _highScoreTextSize:Int = 8;

	private var _finalScoreYPos:Float = (FlxG.height / 2) - 18;
	private var _scoreIconPos:Float = (FlxG.width / 2) - 8;
	private var _scoreTextXPos:Float = (FlxG.width / 2);
	private var _highScoreTextYPos:Float = (FlxG.height / 2) + 10;
	private var _mainMenuButtonYPos:Int = FlxG.height - 32;

	private var _cameraTransitionTime:Float = 0.33;

	private var _winMessageText:String = "You Win!";
	private var _gameOverMessageText:String = "Game Over!";
	private var _finalScoreText:String = "Final Score: ";
	private var _highScoreText:String = "Highscore: ";
	private var _mainMenuButtonText:String = "Main Menu";
	private var _highScoreKey:String = "highScore";

	// ============================================================================================

	public function new(win:Bool, score:Int)
	{
		super();

		_win = win;
		_score = score;
	}

	// ============================================================================================

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end

		_titleField = new FlxText(0, _titleTextYPos, 0, if (_win) _winMessageText else _gameOverMessageText, _titleTextSize);
		_titleField.alignment = CENTER;
		_titleField.screenCenter(FlxAxes.X);
		add(_titleField);

		_finalScoreField = new FlxText(0, _finalScoreYPos, 0, _finalScoreText, _finalScoreSize);
		_finalScoreField.alignment = CENTER;
		_finalScoreField.screenCenter(FlxAxes.X);
		add(_finalScoreField);

		_scoreIcon = new FlxSprite(_scoreIconPos, 0, AssetPaths.coin__png);
		_scoreIcon.screenCenter(FlxAxes.Y);
		add(_scoreIcon);

		_scoreField = new FlxText(_scoreTextXPos, 0, 0, Std.string(_score), _scoreTextSize);
		_scoreField.screenCenter(FlxAxes.Y);
		add(_scoreField);

		var highscore = checkHighscore(_score);

		_highScoreField = new FlxText(0, _highScoreTextYPos, 0, _highScoreText + highscore, _highScoreTextSize);
		_highScoreField.alignment = CENTER;
		_highScoreField.screenCenter(FlxAxes.Y);
		add(_highScoreField);

		_mainMenuButton = new FlxButton(0, _mainMenuButtonYPos, _mainMenuButtonText, switchToMainMenu);
		_mainMenuButton.screenCenter(FlxAxes.X);
		_mainMenuButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(_mainMenuButton);

		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, true);

		super.create();
	}

	// ============================================================================================

	private function checkHighscore(score:Int):Int
	{
		var highscore:Int = score;
		var save = new FlxSave();

		if (save.bind(_highScoreKey))
		{
			if (save.data.highscore != null && save.data.highscore > highscore)
			{
				highscore = save.data.highscore;
			}
			else
			{
				save.data.highscore = highscore;
			}
		}

		save.close();
		return highscore;
	}

	// ============================================================================================

	private function switchToMainMenu():Void
	{
		FlxG.camera.fade(FlxColor.BLACK, _cameraTransitionTime, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}

	// ============================================================================================
}
