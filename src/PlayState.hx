package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	// ============================================================================================
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	private var _coinSound:FlxSound;

	private var _hud:HUD;
	private var _combatHud:CombatHUD;

	private var _coins:FlxTypedGroup<Coin>;
	private var _enemies:FlxTypedGroup<Enemy>;

	private var _player:Player;
	private var _map:FlxOgmo3Loader;
	private var _walls:FlxTilemap;

	private var _wallLayer:String = "walls";
	private var _entitiesKey:String = "entities";
	private var _playerKey:String = "player";
	private var _coinKey:String = "coin";
	private var _enemyKey:String = "enemy";
	private var _bossKey:String = "boss";
	private var _coinSoundDir:String = "assets/sounds/coin.wav";

	private var _coinCount:Int = 0;
	private var _healthCount:Int = 3;
	private var _coinOffset:Int = 4;
	private var _enemyOffset:Int = 4;

	private var _inCombat:Bool = false;
	private var _isEnding:Bool;
	private var _isWon:Bool;

	// ============================================================================================

	override public function create()
	{
		createGameArea();
		createPlayer();

		// Set camera movement type
		FlxG.camera.follow(_player, TOPDOWN, 1);

		_hud = new HUD();
		add(_hud);

		_combatHud = new CombatHUD();
		add(_combatHud);

		_coinSound = FlxG.sound.load(_coinSoundDir);

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		createPlayerFlxG.camera.fade(FlxColor.BLACK, 0.33, true);
		#end

		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		super.create();
	}

	// ============================================================================================

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_isEnding)
		{
			return;
		}

		if (_inCombat)
		{
			if (!_combatHud.visible)
			{
				_healthCount = _combatHud.playerHealth;
				_hud.updateHUD(_healthCount, _coinCount);

				if (_combatHud.outcome == DEFEAT)
				{
					_isEnding = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, onDoneFadeOut);
				}
				else
				{
					if (_combatHud.outcome == VICTORY)
					{
						_combatHud.enemy.kill();

						if (_combatHud.enemy.type == BOSS)
						{
							_isWon = true;
							_isEnding = true;
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, onDoneFadeOut);
						}
					}
					else
					{
						_combatHud.enemy.flicker();
					}

					_inCombat = false;
					_player.active = true;
					_enemies.active = true;

					#if mobile
					virtualPad.visible = true;
					#end
				}
			}
		}
		else
		{
			FlxG.collide(_player, _walls);
			FlxG.collide(_enemies, _walls);
			FlxG.overlap(_player, _coins, onPlayerCollidedCoin);
			FlxG.overlap(_player, _enemies, onPlayerCollidedEnemy);

			_enemies.forEachAlive(checkEnemyVision);
		}
	}

	// ============================================================================================

	private function createGameArea()
	{
		_map = new FlxOgmo3Loader(AssetPaths.dungeonBuster__ogmo, AssetPaths.room_001__json);
		_walls = _map.loadTilemap(AssetPaths.tiles__png, _wallLayer);
		_walls.follow();
		_walls.setTileProperties(1, NONE);
		_walls.setTileProperties(2, ANY);

		_coins = new FlxTypedGroup<Coin>();
		_enemies = new FlxTypedGroup<Enemy>();

		add(_walls);
		add(_coins);
		add(_enemies);
	}

	// ============================================================================================

	private function createPlayer()
	{
		_player = new Player();
		_map.loadEntities(placeEntities, _entitiesKey);

		add(_player);
	}

	// ============================================================================================

	private function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				_player.setPosition(x, y);

			case "coin":
				var newCoin:Coin = new Coin(x + _coinOffset, y + _coinOffset);
				_coins.add(newCoin);

			case "enemy":
				var newEnemy:Enemy = new Enemy(x + _enemyOffset, y, ENEMY);
				_enemies.add(newEnemy);

			case "boss":
				var newBoss:Enemy = new Enemy(x + _enemyOffset, y, BOSS);
				_enemies.add(newBoss);
		}
	}

	// ============================================================================================

	private function onPlayerCollidedCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();

			_coinCount++;
			_hud.updateHUD(_healthCount, _coinCount);

			_coinSound.play(true);
		}
	}

	// ============================================================================================

	private function onPlayerCollidedEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy);
		}
	}

	// ============================================================================================

	private function startCombat(enemy:Enemy)
	{
		_inCombat = true;
		_player.active = false;
		_enemies.active = false;
		_combatHud.initiateCombat(_healthCount, enemy);

		#if mobile
		virtualPad.visible = false;
		#end
	}

	// ============================================================================================

	private function checkEnemyVision(enemy:Enemy)
	{
		if (_walls.ray(enemy.getMidpoint(), _player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = _player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	// ============================================================================================

	private function onDoneFadeOut()
	{
		FlxG.switchState(new GameOverState(_isWon, _coinCount));
	}

	// ============================================================================================
}
