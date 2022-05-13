package;

import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
	// ============================================================================================
	private var _coinTweenDuration:Float = 0.33;

	private var _coinTweenYOffset:Int = 16;
	private var _spriteSize:Int = 8;

	// ============================================================================================

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(AssetPaths.coin__png, false, _spriteSize, _spriteSize);
	}

	// ============================================================================================

	override function kill()
	{
		alive = false;

		FlxTween.tween(this, {alpha: 0, y: y - _coinTweenYOffset}, _coinTweenDuration, {ease: FlxEase.circOut, onComplete: onKillCompleted});
	}

	// ============================================================================================

	private function onKillCompleted(_)
	{
		exists = false;
	}

	// ============================================================================================
}
