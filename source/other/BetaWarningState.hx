package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * First screen: explicit / gore warning.
 * On a fresh save it routes to the language picker first.
 * ENTER = explicit ON | ESC = explicit OFF
 */
class BetaWarningState extends MusicBeatState
{
	var msg:String = "This mod contains explicit / gore content.\nPress ENTER to enable Explicit Mode\nor ESCAPE to keep it disabled.";
	var selectLang:Bool = false;
	var canSelect:Bool = true;
	var transitioning:Bool = false;

	var titleAlphabet:Alphabet;
	var goreWarning:FlxText;

	override function create()
	{
		OHGlobal.init();

		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Warning != null
				&& OHGlobal.lang.languageTree.menus.Warning.msg != null)
			{
				msg = OHGlobal.lang.languageTree.menus.Warning.msg;
			}
		}
		catch (e:Dynamic)
		{
			trace("BetaWarningState: language fallback -> " + e);
		}

		selectLang = OHGlobal.firstTime;

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		titleAlphabet = new Alphabet(0, 20, "Beta Warning", true);
		titleAlphabet.screenCenter(X);
		add(titleAlphabet);

		goreWarning = OHUtil.makeText(16, titleAlphabet.y + titleAlphabet.height + 10, FlxG.width - 32, "", 32, CENTER);
		OHUtil.applyMarkup(goreWarning, msg);
		add(goreWarning);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (selectLang)
		{
			selectLang = false;
			trace("First Time – opening language picker");
			OHUtil.switchState(new OHLanguage(true));
			return;
		}

		if (canSelect && !transitioning)
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				OHGlobal.setExplicit(true);
				trace("Saved: Explicit mode enabled");
				leave();
			}
			else if (FlxG.keys.justPressed.ESCAPE)
			{
				OHGlobal.setExplicit(false);
				trace("Saved: Explicit mode disabled");
				leave();
			}
		}

		super.update(elapsed);
	}

	function leave()
	{
		transitioning = true;
		canSelect = false;
		FlxG.sound.play(Paths.sound('confirmMenu'), 1);
		FlxG.camera.flash(FlxColor.WHITE, 1, function()
		{
			FlxG.camera.fade(FlxColor.BLACK, 2.5, false, goToTitle);
		});
	}

	function goToTitle()
	{
		OHUtil.switchState(new TitleState());
	}
}
