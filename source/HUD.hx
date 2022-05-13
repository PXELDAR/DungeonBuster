package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	// ============================================================================================
	private var _backGround:FlxSprite;
	private var _healthIcon:FlxSprite;
	private var _coinIcon:FlxSprite;

	private var _healthCounter:FlxText;
	private var _coinCounter:FlxText;

	private var _backGroundYPos:Int = 20;
	private var _backGroundRectYPos:Int = 19;
	private var _backGroundRectWidth:Int = 5;

	private var _healthCounterTextXPos:Int = 16;
	private var _healthCounterTextYPos:Int = 2;
	private var _healthCounterTextYSize:Int = 8;
	private var _healthCounterBorderSize:Int = 1;
	private var _healthCounterBorderColor:FlxColor = FlxColor.GRAY;

	private var _healthIconXPos:Int = 4;
	private var _coinIconXPos:Int = FlxG.width - 12;

	private var _coinCounterTextXPos:Int = 0;
	private var _coinCounterTextYPos:Int = 2;
	private var _coinCounterTextSize:Int = 8;
	private var _coinCounterBorderSize:Int = 1;
	private var _coinCounterBorderColor:FlxColor = FlxColor.GRAY;

	private var _healthCounterDefaultText:String = "3 / 3";
	private var _healthCounterMaxText:String = "/ 3";
	private var _coinCounterDefaultText:String = "0";

	// ============================================================================================

	public function new()
	{
		super();

		_backGround = new FlxSprite().makeGraphic(FlxG.width, _backGroundYPos, FlxColor.BLACK);
		_backGround.drawRect(0, _backGroundRectYPos, FlxG.width, _backGroundRectWidth, FlxColor.WHITE);

		_healthCounter = new FlxText(_healthCounterTextXPos, _healthCounterTextYPos, 0, _healthCounterDefaultText, _healthCounterTextYSize);
		_healthCounter.setBorderStyle(SHADOW, _healthCounterBorderColor, _healthCounterBorderSize, 1);

		_coinCounter = new FlxText(_coinCounterTextXPos, _coinCounterTextYPos, 0, _coinCounterDefaultText, _coinCounterTextSize);
		_coinCounter.setBorderStyle(SHADOW, _coinCounterBorderColor, _coinCounterBorderSize, 1);

		_healthIcon = new FlxSprite(_healthIconXPos, _healthCounter.y + (_healthCounter.height / 2) - 4, AssetPaths.health__png);
		_coinIcon = new FlxSprite(_coinIconXPos, _coinCounter.y + (_coinCounter.height / 2) - 4, AssetPaths.coin__png);

		_coinCounter.alignment = RIGHT;
		_coinCounter.x = _coinIcon.x - _coinCounter.width - 4;

		add(_backGround);
		add(_healthCounter);
		add(_coinCounter);
		add(_healthIcon);
		add(_coinIcon);

		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	// ============================================================================================

	public function updateHUD(health:Int, coin:Int)
	{
		_healthCounter.text = health + " " + _healthCounterMaxText;
		_coinCounter.text = Std.string(coin);
		_coinCounter.x = _coinIcon.x - _coinCounter.width - 4;
	}

	// ============================================================================================
}
