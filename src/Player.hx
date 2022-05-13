package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

class Player extends FlxSprite
{
	// ============================================================================================
	private var _stepSound:FlxSound;

	private var _speed:Float = 100;
	private var _playerDragForce:Float = 1600;
	private var _playerAngle:Float;

	private var _spriteSize:Int = 16;
	private var _hitBoxSize:Int = 8;
	private var _hitBoxColliderSize:Int = 4;

	private var _up:Bool;
	private var _down:Bool;
	private var _left:Bool;
	private var _right:Bool;

	private var _leftRightAnimation:String = "LeftRightAnim";
	private var _upAnimation:String = "UpAnim";
	private var _downAnimation:String = "DownAnim";
	private var _playerSpriteDir:String = "assets/images/player.png";
	private var _stepSoundDir:String = "assets/sounds/step.wav";

	// ============================================================================================

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		setPlayerGraphics();

		drag.x = drag.y = _playerDragForce;

		setSize(_hitBoxSize, _hitBoxSize);
		offset.set(_hitBoxColliderSize, _hitBoxColliderSize);

		_stepSound = FlxG.sound.load(_stepSoundDir);
	}

	// ============================================================================================

	override function update(elapsed:Float)
	{
		updateMovement();

		super.update(elapsed);
	}

	// ============================================================================================

	private function setPlayerGraphics()
	{
		loadGraphic(_playerSpriteDir, true, _spriteSize, _spriteSize);

		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);

		// Index order from player sprite
		animation.add(_leftRightAnimation, [3, 4, 3, 5, 3], 5, false);
		animation.add(_upAnimation, [6, 7, 6, 8, 6], 5, false);
		animation.add(_downAnimation, [0, 1, 0, 2, 0], 5, false);
	}

	// ============================================================================================

	private function updateMovement()
	{
		checkInput();
		disableReverseKeyMovement();

		if (_up || _down || _left || _right)
		{
			checkPlayerAngle();
			setPlayerSpeed();
			setPlayerAnimation();
		}
	}

	// ============================================================================================

	private function checkInput()
	{
		#if FLX_KEYBOARD
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
		#end

		#if mobile
		var virtualPad = PlayState.virtualPad;
		_up = _up || virtualPad.buttonUp.pressed;
		_down = _down || virtualPad.buttonDown.pressed;
		_left = _left || virtualPad.buttonLeft.pressed;
		_right = _right || virtualPad.buttonRight.pressed;
		#end
	}

	// ============================================================================================

	private function disableReverseKeyMovement()
	{
		if (_up && _down)
		{
			_up = _down = false;
		}
		else if (_left && _right)
		{
			_left = _right = false;
		}
	}

	// ============================================================================================

	private function checkPlayerAngle()
	{
		if (_up)
		{
			_playerAngle = -90;

			if (_left)
			{
				_playerAngle -= 45;
			}
			else if (_right)
			{
				_playerAngle += 45;
			}

			facing = UP;
		}
		else if (_down)
		{
			_playerAngle = 90;

			if (_left)
			{
				_playerAngle += 45;
			}
			else if (_right)
			{
				_playerAngle -= 45;
			}

			facing = DOWN;
		}
		else if (_left)
		{
			_playerAngle = 180;
			facing = LEFT;
		}
		else if (_right)
		{
			_playerAngle = 0;
			facing = RIGHT;
		}
	}

	// ============================================================================================

	private function setPlayerSpeed()
	{
		// Determine velocity based on angle and speed
		velocity.set(_speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), _playerAngle);
	}

	// ============================================================================================

	private function setPlayerAnimation()
	{
		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
		{
			_stepSound.play();

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
	}

	// ============================================================================================
}
