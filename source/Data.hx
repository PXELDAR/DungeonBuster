class Data
{
	// ============================================================================================
	public static final instance:Data = new Data();

	public var playerMaxHealth:Int = 3;

	public var enemyAttackChange(default, null):Int = 30;
	public var playerAttackChange(default, null):Int = 85;
	public var fleeChance(default, null):Int = 50;

	// ============================================================================================

	private function new() {}

	// ============================================================================================
}
