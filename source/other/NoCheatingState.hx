package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/** Shown when the player presses 7 without debug access. */
class NoCheatingState extends MusicBeatState
{
	var sorrow:FlxSprite;
	var scareText:FlxText;
	var textCam:FlxCamera;

	override function create()
	{
		trace("NO CHEATING!!! >:c");

		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		textCam = new FlxCamera();
		textCam.bgColor = 0;
		FlxG.cameras.add(textCam, false);

		sorrow = new FlxSprite();
		try
		{
			sorrow.loadGraphic(Paths.image("menus/no_cheating"));
		}
		catch (e:Dynamic)
		{
			sorrow.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		sorrow.scrollFactor.set();
		sorrow.setGraphicSize(FlxG.width, FlxG.height);
		sorrow.screenCenter();
		add(sorrow);

		var spanish:Bool = (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr');

		scareText = OHUtil.makeText(0, 0, 0, spanish ? "TRAMPOSO" : "CHEATER", 90);
		scareText.scrollFactor.set();
		scareText.color = FlxColor.RED;
		scareText.screenCenter(X);
		scareText.y = 30;
		scareText.cameras = [textCam];
		add(scareText);

		var sound:String = "cheater" + (spanish ? "-es" : "-en");

		FlxG.camera.flash(FlxColor.RED, 0.2);
		try { FlxG.sound.play(Paths.sound('menu/cheater'), 1); } catch (_:Dynamic) {}

		textCam.shake(0.03, 6.8);

		new FlxTimer().start(1.5, function(_)
		{
			try { FlxG.sound.play(Paths.sound("menu/" + sound), 1); } catch (_:Dynamic) {}
		});
		new FlxTimer().start(6.8, function(_)
		{
			lime.system.System.exit(1);
		});

		super.create();
	}
}
