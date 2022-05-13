package;

import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

enum Outcome
{
	NONE;
	ESCAPE;
	VICTORY;
	DEFEAT;
}

enum Choice
{
	FIGHT;
	FLEE;
}

class CombatHUD extends FlxTypedGroup<FlxSprite>
{
	// ============================================================================================
	public var enemy:Enemy;
	public var playerHealth(default, null):Int;
	public var outcome(default, null):Outcome;

	private var _background:FlxSprite;
	private var _screen:FlxSprite;
	private var _pointer:FlxSprite;

	private var _playerSprite:Player;
	private var _playerHealthCounter:FlxText;

	private var _enemySprite:Enemy;
	private var _enemyHealth:Int;
	private var _enemyMaxHealth:Int;
	private var _enemyHealthBar:FlxBar;

	private var _damages:Array<FlxText>;
	private var _selected:Choice;
	private var _choices:Map<Choice, FlxText>;
	private var _results:FlxText;

	private var _alpha:Float = 0;

	private var _isWait:Bool = true;

	private var _fledSound:FlxSound;
	private var _hurtSound:FlxSound;
	private var _loseSound:FlxSound;
	private var _missSound:FlxSound;
	private var _selectSound:FlxSound;
	private var _winSound:FlxSound;
	private var _combatSound:FlxSound;

	private var _waveStrength:Int = 4;
	private var _waveSpeed:Int = 4;
	private var _backGroundSize:Int = 120;

	private var _playerSpriteXPos:Int = 36;
	private var _playerSpriteYPos:Int = 16;
	private var _enemySpriteXPos:Int = 76;
	private var _enemySpriteYPos:Int = 16;
	private var _playerHealthCounterSize:Int = 8;

	private var _enemyHealthBarWidth:Int = 20;
	private var _enemyHealthBarHeight:Int = 10;
	private var _damageTextWidth:Int = 40;

	private var _playerHealthDefaultText:String = "3 / 3";
	private var _fightText:String = "FIGHT";
	private var _fleeText:String = "FLEE";
	private var _victoryText:String = "VICTORY";
	private var _defeatText:String = "DEFEAT";
	private var _missText:String = "MISS!";
	private var _escapedText:String = "ESCAPED";

	// ============================================================================================

	public function new()
	{
		super();

		_screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, _waveStrength, -1, _waveSpeed);
		var waveSprite = new FlxEffectSprite(_screen, [waveEffect]);
		add(waveSprite);

		_background = new FlxSprite().makeGraphic(_backGroundSize, _backGroundSize, FlxColor.WHITE);
		_background.drawRect(1, 1, 118, 44, FlxColor.BLACK);
		_background.drawRect(1, 46, 118, 73, FlxColor.BLACK);
		_background.screenCenter();
		add(_background);

		_playerSprite = new Player(_background.x + _playerSpriteXPos, _background.y + _playerSpriteYPos);
		_playerSprite.animation.frameIndex = 3;
		_playerSprite.active = false;
		_playerSprite.facing = RIGHT;
		add(_playerSprite);

		_enemySprite = new Enemy(_background.x + _enemySpriteXPos, _background.y + _enemySpriteYPos, ENEMY);
		_enemySprite.animation.frameIndex = 3;
		_enemySprite.active = false;
		_enemySprite.facing = LEFT;
		add(_enemySprite);

		_playerHealthCounter = new FlxText(0, _playerSprite.y + _playerSprite.height + 2, 0, _playerHealthDefaultText, _playerHealthCounterSize);
		_playerHealthCounter.alignment = CENTER;
		_playerHealthCounter.x = _playerSprite.x + 4 - (_playerHealthCounter.width / 2);
		add(_playerHealthCounter);

		_enemyHealthBar = new FlxBar(_enemySprite.x - 6, _playerHealthCounter.y, LEFT_TO_RIGHT, _enemyHealthBarWidth, _enemyHealthBarHeight);
		_enemyHealthBar.createFilledBar(0xffdc143c, FlxColor.YELLOW, true, FlxColor.YELLOW);
		add(_enemyHealthBar);

		_choices = new Map();
		_choices[FIGHT] = new FlxText(_background.x + 30, _background.y + 48, 85, _fightText, 22);
		_choices[FLEE] = new FlxText(_background.x + 30, _choices[FIGHT].y + _choices[FIGHT].height + 8, 85, _fleeText, 22);
		add(_choices[FIGHT]);
		add(_choices[FLEE]);

		_pointer = new FlxSprite(_background.x + 10, _choices[FIGHT].y + (_choices[FIGHT].height / 2) - 8, AssetPaths.pointer__png);
		_pointer.visible = false;
		add(_pointer);

		_damages = new Array<FlxText>();
		_damages.push(new FlxText(0, 0, _damageTextWidth));
		_damages.push(new FlxText(0, 0, _damageTextWidth));
		for (d in _damages)
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(SHADOW, FlxColor.RED);
			d.alignment = CENTER;
			d.visible = false;
			add(d);
		}

		_results = new FlxText(_background.x + 2, _background.y + 9, 116, "", 18);
		_results.alignment = CENTER;
		_results.color = FlxColor.YELLOW;
		_results.setBorderStyle(SHADOW, FlxColor.GRAY);
		_results.visible = false;
		add(_results);

		forEach(function(sprite:FlxSprite)
		{
			sprite.scrollFactor.set();
			sprite.alpha = 0;
		});

		active = false;
		visible = false;

		_fledSound = FlxG.sound.load(AssetPaths.fled__wav);
		_hurtSound = FlxG.sound.load(AssetPaths.hurt__wav);
		_loseSound = FlxG.sound.load(AssetPaths.lose__wav);
		_missSound = FlxG.sound.load(AssetPaths.miss__wav);
		_selectSound = FlxG.sound.load(AssetPaths.select__wav);
		_winSound = FlxG.sound.load(AssetPaths.win__wav);
		_combatSound = FlxG.sound.load(AssetPaths.combat__wav);
	}

	// ============================================================================================

	override public function update(elapsed:Float)
	{
		#if FLX_KEYBOARD
		if (!_isWait)
		{
			updateKeyboardInput();
			updateTouchInput();
		}
		super.update(elapsed);
		#end
	}

	// ============================================================================================

	public function initiateCombat(playerHealth:Int, enemy:Enemy)
	{
		_screen.drawFrame();
		var screenPixels = _screen.framePixels;

		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));

		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(),
			new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));

		_combatSound.play();
		this.playerHealth = playerHealth;
		this.enemy = enemy;

		updatePlayerHealth();

		_enemyMaxHealth = _enemyHealth = if (enemy.type == ENEMY) 2 else 4;
		_enemyHealthBar.value = 100;
		_enemySprite.changeType(enemy.type);

		_isWait = true;
		_results.text = "";
		_pointer.visible = false;
		_results.visible = false;
		outcome = NONE;
		_selected = FIGHT;
		movePointer();

		visible = true;

		FlxTween.num(0, 1, .66, {ease: FlxEase.circOut, onComplete: finishFadeIn}, updateAlpha);
	}

	// ============================================================================================

	private function updateAlpha(alpha:Float)
	{
		_alpha = alpha;
		forEach(function(sprite) sprite.alpha = alpha);
	}

	// ============================================================================================

	private function finishFadeIn(_)
	{
		active = true;
		_isWait = false;
		_pointer.visible = true;
		_selectSound.play();
	}

	// ============================================================================================

	private function finishFadeOut(_)
	{
		active = false;
		visible = false;
	}

	// ============================================================================================

	private function updatePlayerHealth()
	{
		_playerHealthCounter.text = playerHealth + "/" + Std.string(Data.instance.playerMaxHealth);
		_playerHealthCounter.x = _playerSprite.x + 4 - (_playerHealthCounter.width / 2);
	}

	// ============================================================================================

	private function updateKeyboardInput()
	{
		#if FLX_KEYBOARD
		var up:Bool = false;
		var down:Bool = false;
		var fire:Bool = false;

		if (FlxG.keys.anyJustReleased([SPACE, X, ENTER]))
		{
			fire = true;
		}
		else if (FlxG.keys.anyJustReleased([W, UP]))
		{
			up = true;
		}
		else if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			down = true;
		}

		if (fire)
		{
			_selectSound.play();
			makeChoice();
		}
		else if (up || down)
		{
			_selected = if (_selected == FIGHT) FLEE else FIGHT;
			_selectSound.play();
			movePointer();
		}
		#end
	}

	// ============================================================================================

	private function updateTouchInput()
	{
		#if FLX_TOUCH
		for (touch in FlxG.touches.justReleased())
		{
			for (choice in _choices.keys())
			{
				var text = _choices[choice];
				if (touch.overlaps(text))
				{
					_selectSound.play();
					_selected = choice;
					movePointer();
					makeChoice();
					return;
				}
			}
		}
		#end
	}

	// ============================================================================================

	private function movePointer()
	{
		_pointer.y = _choices[_selected].y + (_choices[_selected].height / 2) - 8;
	}

	// ============================================================================================

	private function makeChoice()
	{
		_pointer.visible = false;
		switch (_selected)
		{
			case FIGHT:
				if (FlxG.random.bool(Data.instance.playerAttackChange))
				{
					_damages[1].text = "1";
					FlxTween.tween(_enemySprite, {x: _enemySprite.x + 4}, 0.1, {
						onComplete: function(_)
						{
							FlxTween.tween(_enemySprite, {x: _enemySprite.x - 4}, 0.1);
						}
					});

					_hurtSound.play();
					_enemyHealth--;
					_enemyHealthBar.value = (_enemyHealth / _enemyMaxHealth) * 100;
				}
				else
				{
					_damages[1].text = _missText;
					_missSound.play();
				}

				_damages[1].x = _enemySprite.x + 2 - (_damages[1].width / 2);
				_damages[1].y = _enemySprite.y + 4 - (_damages[1].height / 2);
				_damages[1].alpha = 0;
				_damages[1].visible = true;

				if (_enemyHealth > 0)
				{
					enemyAttack();
				}

				FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);

			case FLEE:
				if (FlxG.random.bool(Data.instance.fleeChance))
				{
					outcome = ESCAPE;
					_results.text = _escapedText;
					_fledSound.play();
					_results.visible = true;
					_results.alpha = 0;
					FlxTween.tween(_results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
				}
				else
				{
					enemyAttack();
					FlxTween.num(_damages[0].y, _damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
					FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
				}
		}

		_isWait = true;
	}

	// ============================================================================================

	private function enemyAttack()
	{
		if (FlxG.random.bool(Data.instance.enemyAttackChange))
		{
			FlxG.camera.flash(FlxColor.WHITE, .2);
			FlxG.camera.shake(0.01, 0.2);
			_hurtSound.play();
			_damages[0].text = "1";
			playerHealth--;
			updatePlayerHealth();
		}
		else
		{
			_damages[0].text = _missText;
			_missSound.play();
		}

		_damages[0].x = _playerSprite.x + 2 - (_damages[0].width / 2);
		_damages[0].y = _playerSprite.y + 4 - (_damages[0].height / 2);
		_damages[0].alpha = 0;
		_damages[0].visible = true;
	}

	// ============================================================================================

	private function updateDamageY(damageY:Float)
	{
		_damages[0].y = _damages[1].y = damageY;
	}

	// ============================================================================================

	private function updateDamageAlpha(damageAlpha:Float)
	{
		_damages[0].alpha = _damages[1].alpha = damageAlpha;
	}

	// ============================================================================================

	private function doneDamageIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
	}

	// ============================================================================================

	private function doneResultsIn(_)
	{
		FlxTween.num(1, 0, .66, {ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1}, updateAlpha);
	}

	// ============================================================================================

	private function doneDamageOut(_)
	{
		_damages[0].visible = false;
		_damages[1].visible = false;
		_damages[0].text = "";
		_damages[1].text = "";

		if (playerHealth <= 0)
		{
			outcome = DEFEAT;
			_loseSound.play();
			_results.text = _defeatText;
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else if (_enemyHealth <= 0)
		{
			outcome = VICTORY;
			_winSound.play();
			_results.text = _victoryText;
			_results.visible = true;
			_results.alpha = 0;
			FlxTween.tween(_results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else
		{
			_isWait = false;
			_pointer.visible = true;
		}
	}

	// ============================================================================================
}
