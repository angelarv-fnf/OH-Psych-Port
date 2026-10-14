package backend;

import flixel.FlxG;

/**
 * Global state for Other Halloween (Psych 0.7.3 port).
 * Mirrors the original Codename global.hx behaviour.
 */
class OHGlobal
{
	public static var lang:LanguageManager = null;
	public static var explicitMode:Bool = false;
	public static var firstTime:Bool = true;
	public static var debugMode:Bool = false;
	public static var initialized:Bool = false;

	/** Call once at boot (Title / BetaWarning). */
	public static function init():Void
	{
		if (initialized) return;
		initialized = true;

		// First-time defaults
		if (FlxG.save.data.enLang == null && FlxG.save.data.esLang == null && FlxG.save.data.expMode == null)
		{
			trace("First time in this mod? Initializing setup...");
			FlxG.save.data.enLang = true;
			FlxG.save.data.esLang = false;
			FlxG.save.data.expMode = false;
			FlxG.save.data.completedRed = false;
			FlxG.save.flush();
			firstTime = true;
		}
		else
		{
			firstTime = false;
		}

		var savedLang:String = (FlxG.save.data.esLang == true) ? 'es-pr' : 'en-us';
		lang = new LanguageManager(savedLang);
		explicitMode = (FlxG.save.data.expMode == true);

		// Optional debug flag (set via save or compile define)
		#if debug
		debugMode = true;
		#end
		if (FlxG.save.data.ohDebug == true)
			debugMode = true;

		trace("OHGlobal initialized | lang=" + savedLang + " | explicit=" + explicitMode + " | firstTime=" + firstTime);
	}

	public static function setExplicit(value:Bool):Void
	{
		explicitMode = value;
		FlxG.save.data.expMode = value;
		FlxG.save.flush();
	}

	public static function setLanguage(code:String):Void
	{
		if (lang != null)
			lang.setLanguage(code);

		if (code == 'es-pr')
		{
			FlxG.save.data.enLang = false;
			FlxG.save.data.esLang = true;
		}
		else
		{
			FlxG.save.data.enLang = true;
			FlxG.save.data.esLang = false;
		}
		FlxG.save.flush();
	}
}
