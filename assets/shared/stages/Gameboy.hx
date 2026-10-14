package states.stages;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import states.PlayState;
import backend.BaseStage;

/**
 * Port of Codename "gameboy" stage → Psych Engine 0.7.3
 * Pixel stage with optional family car appearance on beat 176 of "game-on"
 */
class Gameboy extends BaseStage
{
	var familyCar:FlxSprite;
	var stageBack:FlxSprite;
	var threeStageBack:FlxSprite;
	var wireStageBack:FlxSprite;

	override function create()
	{
		// Background layers
		stageBack = new FlxSprite(-600, -200).loadGraphic(Paths.image('stages/gameboy/stageback'));
		stageBack.antialiasing = false;
		add(stageBack);

		threeStageBack = new FlxSprite(-603, -346).loadGraphic(Paths.image('stages/gameboy/THREEStageBack'));
		threeStageBack.scale.set(0.8, 0.8);
		threeStageBack.updateHitbox();
		threeStageBack.antialiasing = false;
		threeStageBack.visible = false;
		add(threeStageBack);

		wireStageBack = new FlxSprite(-603, -346).loadGraphic(Paths.image('stages/gameboy/WIREStageBack'));
		wireStageBack.scale.set(0.8, 0.8);
		wireStageBack.updateHitbox();
		wireStageBack.antialiasing = false;
		wireStageBack.visible = false;
		add(wireStageBack);
	}

	override function createPost()
	{
		if (gf != null)
			gf.visible = false;

		familyCar = new FlxSprite(375, 460).loadGraphic(Paths.image('stages/gameboy/family_car'));
		familyCar.scale.set(1.2, 1.2);
		familyCar.updateHitbox();
		familyCar.antialiasing = false;
		familyCar.visible = false;
		add(familyCar);
	}

	override function beatHit()
	{
		if (curBeat == 176 && PlayState.SONG != null && Paths.formatToSongPath(PlayState.SONG.song) == 'game-on')
		{
			if (familyCar != null)
				familyCar.visible = true;
		}
	}
}
