package states.stages;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import states.PlayState;
import backend.BaseStage;

/**
 * Port of Codename "gameboy_new" stage → Psych Engine 0.7.3
 * Daytime city / sea pixel stage with sun + car, hides BG and sinks sun on specific beats of "game-on"
 */
class GameboyNew extends BaseStage
{
	var bg:FlxSprite;
	var bgDay:FlxSprite;
	var sun:FlxSprite;
	var city:FlxSprite;
	var sea:FlxSprite;
	var mountain:FlxSprite;
	var floor:FlxSprite;
	var carFamily:FlxSprite;
	var hideBG:FlxSprite;

	override function create()
	{
		bg = new FlxSprite(-689, -297).loadGraphic(Paths.image('stages/gameboy_new/stageBack'));
		bg.antialiasing = false;
		add(bg);

		bgDay = new FlxSprite(0, -636).loadGraphic(Paths.image('stages/gameboy_new/green_sky'));
		bgDay.scale.set(1.5, 1.5);
		bgDay.updateHitbox();
		bgDay.scrollFactor.set(0, 0);
		bgDay.antialiasing = false;
		add(bgDay);

		sun = new FlxSprite(-351, -112).loadGraphic(Paths.image('stages/gameboy_new/green_sun'));
		sun.scale.set(1.7, 1.7);
		sun.updateHitbox();
		sun.scrollFactor.set(0.6, 0.6);
		sun.antialiasing = false;
		add(sun);

		city = new FlxSprite(181, -366);
		if (Paths.fileExists('images/stages/gameboy_new/city.png', IMAGE))
		{
			city.frames = Paths.getSparrowAtlas('stages/gameboy_new/city');
			city.animation.addByPrefix('idle', 'city', 24, true);
			city.animation.play('idle');
		}
		else
			city.loadGraphic(Paths.image('stages/gameboy_new/city'));
		city.scale.set(1.5, 1.5);
		city.updateHitbox();
		city.scrollFactor.set(0.6, 0.6);
		city.antialiasing = false;
		add(city);

		sea = new FlxSprite(-63, 269);
		if (Paths.fileExists('images/stages/gameboy_new/gb_sea.png', IMAGE))
		{
			sea.frames = Paths.getSparrowAtlas('stages/gameboy_new/gb_sea');
			sea.animation.addByPrefix('idle', 'gb_sea', 24, true);
			sea.animation.play('idle');
		}
		else
			sea.loadGraphic(Paths.image('stages/gameboy_new/gb_sea'));
		sea.scale.set(1.65, 1.65);
		sea.updateHitbox();
		sea.scrollFactor.set(0.6, 0.6);
		sea.antialiasing = false;
		add(sea);

		mountain = new FlxSprite(-86, 262).loadGraphic(Paths.image('stages/gameboy_new/mountain'));
		mountain.scale.set(1.6, 1.6);
		mountain.updateHitbox();
		mountain.scrollFactor.set(0.8, 0.8);
		mountain.antialiasing = false;
		add(mountain);

		floor = new FlxSprite(-55, 495).loadGraphic(Paths.image('stages/gameboy_new/floor_grass'));
		floor.scale.set(1.5, 1.5);
		floor.updateHitbox();
		floor.antialiasing = false;
		add(floor);

		carFamily = new FlxSprite(435, 370).loadGraphic(Paths.image('stages/gameboy_new/car_family'));
		carFamily.scale.set(1.2, 1.2);
		carFamily.updateHitbox();
		carFamily.antialiasing = false;
		add(carFamily);

		// Overlay that hides the day BG until a certain beat
		hideBG = new FlxSprite(-810, -405).loadGraphic(Paths.image('stages/gameboy_new/stageBack'));
		hideBG.scrollFactor.set(0, 0);
		hideBG.antialiasing = false;
		add(hideBG);
	}

	override function createPost()
	{
		if (gf != null)
			gf.visible = false;
	}

	override function beatHit()
	{
		if (PlayState.SONG == null) return;
		var songName = Paths.formatToSongPath(PlayState.SONG.song);

		if (songName == 'game-on')
		{
			if (curBeat == 48)
			{
				if (hideBG != null)
					hideBG.visible = false;
			}
			else if (curBeat == 176)
			{
				if (bgDay != null)
					FlxTween.tween(bgDay, {y: bgDay.y + 1000, alpha: 0}, 4, {ease: FlxEase.quadIn});
				if (sun != null)
					FlxTween.tween(sun, {y: sun.y + 700}, 4, {ease: FlxEase.quadIn});
			}
		}
	}
}
