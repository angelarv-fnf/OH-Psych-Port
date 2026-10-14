package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;

/**
 * Title screen with intro text sequence + VCR shader.
 * Updated: no longer hard-references Codename in the default path when language JSON is present.
 */
class TitleState extends MusicBeatState
{
	public static var ended:Bool = false;

	// Psych compatibility
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;
	public static var closedState:Bool = false;

	var texts:Array<String> = [
		"Original Game by\n*FunkinCrew*",
		"Psych Engine by\n*ShadowMario*",
		"Mod created by\n*Sexy Team*",
		"Directed by\n*EstudiOmega*",
		"this",
		"is"
	];
	var enter:String = "Press ENTER to Start";
	var colors:Array<FlxColor> = [FlxColor.CYAN, FlxColor.GRAY, FlxColor.PINK, FlxColor.RED];

	var introTexts:FlxTypedGroup<FlxText>;
	var title:FlxText;
	var enterText:FlxText;
	var demoText:FlxText;
	var showText:FlxTimer;

	var vcr:FlxRuntimeShader;
	var looptime:Float = 0;
	var loops:Int = 0;

	var skippedIntro:Bool = false;
	var transitioning:Bool = false;

	override function create()
	{
		OHGlobal.init();
		Paths.clearStoredMemory();

		persistentUpdate = persistentDraw = true;
		FlxG.mouse.visible = false;

		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Title != null)
			{
				var t = OHGlobal.lang.languageTree.menus.Title;
				if (t.introTexts != null) texts = t.introTexts;
				if (t.enterText != null) enter = t.enterText;
			}
		}
		catch (e:Dynamic)
		{
			trace("TitleState: language fallback -> " + e);
		}

		// Replace Codename credit with Psych when using fallback
		for (i in 0...texts.length)
		{
			if (texts[i].indexOf("Codename") != -1 || texts[i].indexOf("YoshiCrafter") != -1)
				texts[i] = "Psych Engine by\n*ShadowMario*";
		}

		vcr = OHUtil.setupVCR();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		introTexts = new FlxTypedGroup<FlxText>();
		add(introTexts);

		if (!ended)
		{
			for (i in 0...texts.length)
			{
				var text = OHUtil.makeText(0, 0, 0, "", 100, CENTER);
				if (i < 4)
					text.applyMarkup(texts[i], [new FlxTextFormatMarkerPair(new FlxTextFormat(colors[i % colors.length]), "*")]);
				else
					text.text = texts[i];

				text.ID = i;
				text.updateHitbox();
				text.screenCenter();
				text.alpha = 0;
				text.scrollFactor.set();
				introTexts.add(text);
			}
			loops = introTexts.length;
		}

		title = OHUtil.makeText(0, 0, 0, "", 100, CENTER);
		OHUtil.applyMarkup(title, "FNF\n*O*THER HALL*O*WEEN");
		title.scrollFactor.set();
		title.updateHitbox();
		title.screenCenter();
		title.y -= 200;
		add(title);

		enterText = OHUtil.makeText(0, 0, 0, enter, 75);
		enterText.scrollFactor.set();
		enterText.screenCenter();
		enterText.y += 200;
		add(enterText);

		demoText = OHUtil.makeText(0, enterText.y + enterText.height + 50, 0, "Demo-H1", 32);
		demoText.screenCenter(X);
		add(demoText);

		if (!ended)
		{
			title.alpha = 0;
			enterText.alpha = 0;
			showText = new FlxTimer().start(4, onIntroTick, loops + 2);
		}
		else
		{
			skippedIntro = true;
			title.alpha = 1;
			enterText.alpha = 1;
		}

		super.create();
		Paths.clearUnusedMemory();
	}

	function onIntroTick(t:FlxTimer)
	{
		var loop:Int = t.elapsedLoops - 1;

		if (loop == 6)
		{
			if (introTexts != null && introTexts.length > 0)
				introTexts.members[introTexts.length - 1].alpha = 0;
			try { FlxG.sound.play(Paths.sound('menu/terror_title'), 0.8); } catch (_:Dynamic) {}
			return;
		}
		if (loop > 6)
		{
			finishIntro();
			return;
		}

		if (introTexts != null)
		{
			introTexts.forEach(function(spr:FlxText)
			{
				spr.alpha = (spr.ID == loop) ? 1 : 0;
			});
		}
	}

	function finishIntro()
	{
		ended = true;
		skippedIntro = true;
		if (title != null) title.alpha = 1;
		if (enterText != null) enterText.alpha = 1;
	}

	function skipIntro()
	{
		if (showText != null) showText.cancel();
		if (introTexts != null)
		{
			introTexts.forEach(function(spr:FlxText)
			{
				spr.alpha = 0;
			});
		}
		finishIntro();
	}

	function enterMenu()
	{
		transitioning = true;
		try { FlxG.sound.play(Paths.sound('confirmMenu'), 0.7); } catch (_:Dynamic) {}
		FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);

		new FlxTimer().start(2, function(_)
		{
			OHUtil.switchState(new MainMenuState());
		});
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		if (!transitioning && controls.ACCEPT)
		{
			if (!skippedIntro) skipIntro();
			else enterMenu();
		}

		super.update(elapsed);
	}
}
