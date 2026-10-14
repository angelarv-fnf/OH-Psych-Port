package states.stages;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import backend.BaseStage;

/**
 * Port of Codename "red" stage → Psych Engine 0.7.3
 * Large city stage with many on-beat animated props (sun, people, cherri, etc.)
 */
class Red extends BaseStage
{
	var sky:FlxSprite;
	var sun:FlxSprite;
	var city:FlxSprite;
	var grass:FlxSprite;
	var satsi:FlxSprite;
	var apartments:FlxSprite;
	var cal:FlxSprite;
	var night:FlxSprite;
	var yelion:FlxSprite;
	var edux:FlxSprite;
	var people1:FlxSprite;
	var cherri:FlxSprite;
	var people2:FlxSprite;
	var gapa:FlxSprite;

	var onBeatSprites:Array<FlxSprite> = [];

	override function create()
	{
		// Sky
		sky = new FlxSprite(-673, -484).loadGraphic(Paths.image('stages/red/sky'));
		sky.scale.set(1.2, 1.2);
		sky.updateHitbox();
		sky.scrollFactor.set(0.2, 0.7);
		sky.antialiasing = ClientPrefs.data.antialiasing;
		add(sky);

		// Sun (onbeat)
		sun = new FlxSprite(-466, -426);
		if (Paths.fileExists('images/stages/red/sun/happysun.xml', TEXT))
		{
			sun.frames = Paths.getSparrowAtlas('stages/red/sun/happysun');
			sun.animation.addByPrefix('idle', 'happysun idle', 24, false);
			sun.animation.play('idle');
		}
		else
			sun.loadGraphic(Paths.image('stages/red/sun/happysun'));
		sun.scale.set(1.2, 1.2);
		sun.updateHitbox();
		sun.scrollFactor.set(0.5, 1);
		sun.antialiasing = ClientPrefs.data.antialiasing;
		add(sun);
		onBeatSprites.push(sun);

		// City
		city = new FlxSprite(-701, -552).loadGraphic(Paths.image('stages/red/city'));
		city.scale.set(1.2, 1.2);
		city.updateHitbox();
		city.scrollFactor.set(0.5, 1);
		city.antialiasing = ClientPrefs.data.antialiasing;
		add(city);

		// Grass
		grass = new FlxSprite(-732, 116).loadGraphic(Paths.image('stages/red/lil_grass'));
		grass.scale.set(1.2, 1.2);
		grass.updateHitbox();
		grass.scrollFactor.set(0.8, 0.9);
		grass.antialiasing = ClientPrefs.data.antialiasing;
		add(grass);

		// Satsi (loop)
		satsi = new FlxSprite(-500, -104);
		if (Paths.fileExists('images/stages/red/satsi/satsi.xml', TEXT))
		{
			satsi.frames = Paths.getSparrowAtlas('stages/red/satsi/satsi');
			satsi.animation.addByPrefix('idle', 'satsi', 24, true);
			satsi.animation.play('idle');
		}
		else
			satsi.loadGraphic(Paths.image('stages/red/satsi/satsi'));
		satsi.scrollFactor.set(0.95, 0.95);
		satsi.antialiasing = ClientPrefs.data.antialiasing;
		add(satsi);

		// Apartments
		apartments = new FlxSprite(-684, -454).loadGraphic(Paths.image('stages/red/apartment'));
		apartments.scale.set(1.22, 1.22);
		apartments.updateHitbox();
		apartments.antialiasing = ClientPrefs.data.antialiasing;
		add(apartments);

		// Candela (onbeat)
		cal = new FlxSprite(528, 10);
		if (Paths.fileExists('images/stages/red/candel/candela.xml', TEXT))
		{
			cal.frames = Paths.getSparrowAtlas('stages/red/candel/candela');
			cal.animation.addByPrefix('idle', 'candela idle', 24, false);
			cal.animation.play('idle');
		}
		else
			cal.loadGraphic(Paths.image('stages/red/candel/candela'));
		cal.antialiasing = ClientPrefs.data.antialiasing;
		add(cal);
		onBeatSprites.push(cal);

		// Night (onbeat)
		night = new FlxSprite(780, 16);
		if (Paths.fileExists('images/stages/red/night/noche.xml', TEXT))
		{
			night.frames = Paths.getSparrowAtlas('stages/red/night/noche');
			night.animation.addByPrefix('idle', 'noche idle', 24, false);
			night.animation.play('idle');
		}
		else
			night.loadGraphic(Paths.image('stages/red/night/noche'));
		night.antialiasing = ClientPrefs.data.antialiasing;
		add(night);
		onBeatSprites.push(night);

		// Yelion (onbeat)
		yelion = new FlxSprite(246, 12);
		if (Paths.fileExists('images/stages/red/yelion/yelo.xml', TEXT))
		{
			yelion.frames = Paths.getSparrowAtlas('stages/red/yelion/yelo');
			yelion.animation.addByPrefix('idle', 'yelo idle', 24, false);
			yelion.animation.play('idle');
		}
		else
			yelion.loadGraphic(Paths.image('stages/red/yelion/yelo'));
		yelion.antialiasing = ClientPrefs.data.antialiasing;
		add(yelion);
		onBeatSprites.push(yelion);

		// Edux (loop)
		edux = new FlxSprite(194, 346);
		if (Paths.fileExists('images/stages/red/edux/edux.xml', TEXT))
		{
			edux.frames = Paths.getSparrowAtlas('stages/red/edux/edux');
			edux.animation.addByPrefix('idle', 'edux', 24, true);
			edux.animation.play('idle');
		}
		else
			edux.loadGraphic(Paths.image('stages/red/edux/edux'));
		edux.scale.set(0.9, 0.9);
		edux.updateHitbox();
		edux.antialiasing = ClientPrefs.data.antialiasing;
		add(edux);

		// People 1 (onbeat)
		people1 = new FlxSprite(-680, 148);
		if (Paths.fileExists('images/stages/red/people1/people1.xml', TEXT))
		{
			people1.frames = Paths.getSparrowAtlas('stages/red/people1/people1');
			people1.animation.addByPrefix('idle', 'people1 idle', 24, false);
			people1.animation.play('idle');
		}
		else
			people1.loadGraphic(Paths.image('stages/red/people1/people1'));
		people1.scale.set(1.15, 1.15);
		people1.updateHitbox();
		people1.antialiasing = ClientPrefs.data.antialiasing;
		add(people1);
		onBeatSprites.push(people1);

		// Cherri (dance Left/Right onbeat)
		cherri = new FlxSprite(704, 286);
		if (Paths.fileExists('images/stages/red/cherri/cherri.xml', TEXT))
		{
			cherri.frames = Paths.getSparrowAtlas('stages/red/cherri/cherri');
			cherri.animation.addByIndices('danceRight', 'cherri idle', [0,1,2,3,4,5,6,7,8,9,10], "", 24, false);
			cherri.animation.addByIndices('danceLeft', 'cherri idle', [11,12,13,14,15,16,17,18,19,20,21], "", 24, false);
			cherri.animation.play('danceLeft');
		}
		else
			cherri.loadGraphic(Paths.image('stages/red/cherri/cherri'));
		cherri.antialiasing = ClientPrefs.data.antialiasing;
		add(cherri);

		// People 2 (onbeat)
		people2 = new FlxSprite(940, 74);
		if (Paths.fileExists('images/stages/red/people2/people2.xml', TEXT))
		{
			people2.frames = Paths.getSparrowAtlas('stages/red/people2/people2');
			people2.animation.addByPrefix('idle', 'people2 idle', 24, false);
			people2.animation.play('idle');
		}
		else
			people2.loadGraphic(Paths.image('stages/red/people2/people2'));
		people2.scale.set(1.15, 1.15);
		people2.updateHitbox();
		people2.antialiasing = ClientPrefs.data.antialiasing;
		add(people2);
		onBeatSprites.push(people2);

		// Gapa
		gapa = new FlxSprite(1804, 472).loadGraphic(Paths.image('stages/red/gapa/gapa'));
		gapa.antialiasing = ClientPrefs.data.antialiasing;
		add(gapa);
	}

	override function createPost()
	{
		if (gf != null)
		{
			gf.scale.set(0.9, 0.9);
			gf.updateHitbox();
			gf.setPosition(412, 116);
		}
		if (dad != null)
			dad.setPosition(-103, 171);
		if (boyfriend != null)
			boyfriend.setPosition(948, 350); // approximate, original had no explicit Y
	}

	var danceLeft:Bool = false;

	override function beatHit()
	{
		// Replay on-beat animations
		for (spr in onBeatSprites)
		{
			if (spr != null && spr.animation != null && spr.animation.getByName('idle') != null)
				spr.animation.play('idle', true);
		}

		// Cherri dances every beat
		if (cherri != null && cherri.animation != null)
		{
			danceLeft = !danceLeft;
			cherri.animation.play(danceLeft ? 'danceLeft' : 'danceRight', true);
		}
	}
}
