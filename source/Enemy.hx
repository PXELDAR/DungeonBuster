package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil;

private enum EnemyType
{
	ENEMY;
	BOSS;
}

class Enemy extends FlxSprite
{
	// ============================================================================================
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;
	public var type:EnemyType;

	private var _stepSound:FlxSound;
	private var _brain:FiniteStateMachine;

	private var _enemyStepSoundVolume:Float = 0.4;
	private var _speed:Float = 100;
	private var _idleTimer:Float;
	private var _moveDirection:Float;

	private var _spriteSize:Int = 16;
	private var _dragForce:Int = 10;
	private var _colliderOffsetX:Int = 4;
	private var _colliderOffsetY:Int = 2;
	private var _enemyHitboxHeight:Int = 14;
	private var _enemyHitboxWidth:Int = 8;
	private var _idleTimerMinValue:Int = 1;
	private var _idleTimerMaxValue:Int = 8;
	private var _animationFramePerSecond = 5;

	private var _leftRightAnimation:String = "LeftRightAnim";
	private var _upAnimation:String = "UpAnim";
	private var _downAnimation:String = "DownAnim";

	// ============================================================================================

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);

		this.type = type;

		setEnemyGraphics(type);

		_brain = new FiniteStateMachine(idle);
		_idleTimer = 0;
		playerPosition = FlxPoint.get();

		_stepSound = FlxG.sound.load(AssetPaths.step__wav, _enemyStepSoundVolume);
		_stepSound.proximity(x, y, FlxG.camera.target, FlxG.width * 0.6);
	}

	// ============================================================================================

	override function update(elapsed:Float)
	{
		if (this.isFlickering())
			return;

		updateMovement();

		_brain.update(elapsed);

		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			_stepSound.setPosition(x + frameWidth / 2, y + height);
			_stepSound.play();
		}

		super.update(elapsed);
	}

	// ============================================================================================

	private function setEnemyGraphics(type:EnemyType)
	{
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, _spriteSize, _spriteSize);

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);

		// Index order from player sprite
		animation.add(_downAnimation, [0, 1, 0, 2, 0], _animationFramePerSecond, false);
		animation.add(_leftRightAnimation, [3, 4, 3, 5, 3], _animationFramePerSecond, false);
		animation.add(_upAnimation, [6, 7, 6, 8, 6], _animationFramePerSecond, false);
	}

	// ============================================================================================

	private function setEnemyParameters()
	{
		drag.x = drag.y = _dragForce;
		width = _enemyHitboxWidth;
		height = _enemyHitboxHeight;
		offset.set(_colliderOffsetX, _colliderOffsetY);
	}

	// ============================================================================================

	private function updateMovement()
	{
		checkEnemyAngle();
		setEnemyAnimation();
	}

	// ============================================================================================

	private function checkEnemyAngle()
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
				{
					facing = LEFT;
				}
				else
				{
					facing = RIGHT;
				}
			}
			else
			{
				if (velocity.y < 0)
				{
					facing = DOWN;
				}
				else
				{
					facing = UP;
				}
			}
		}
	}

	// ============================================================================================

	private function setEnemyAnimation()
	{
		switch (facing)
		{
			case LEFT, RIGHT:
				animation.play(_leftRightAnimation);

			case UP:
				animation.play(_upAnimation);

			case DOWN:
				animation.play(_downAnimation);

			case _:
		}
	}

	// ============================================================================================

	private function idle(elapsed:Float)
	{
		if (seesPlayer)
		{
			_brain.activeState = chase;
		}
		else if (_idleTimer <= 0)
		{
			if (FlxG.random.bool(1))
			{
				_moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			else
			{
				_moveDirection = FlxG.random.int(0, 8) * 45;

				// Determine velocity based on angle and speed
				velocity.set(_speed * 0.5, 0);
				velocity.rotate(FlxPoint.weak(), _moveDirection);
			}

			_idleTimer = FlxG.random.int(_idleTimerMinValue, _idleTimerMaxValue);
		}
		else
		{
			_idleTimer -= elapsed;
		}
	}

	// ============================================================================================

	private function chase(elapsed:Float)
	{
		if (!seesPlayer)
		{
			_brain.activeState = idle;
		}
		else
		{
			FlxVelocity.moveTowardsPoint(this, playerPosition, Std.int(_speed));
		}
	}

	// ============================================================================================

	public function changeType(type:EnemyType)
	{
		if (this.type != type)
		{
			this.type = type;
			var graphics = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
			loadGraphic(graphics, true, _spriteSize);
		}
	}

	// ============================================================================================
}
