package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxColor;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import backend.Highscore;
import backend.Song;
import backend.WeekData;
import backend.Difficulty;
#if MODS_ALLOWED
import backend.Mods;
#end

typedef OHSongEntry =
{
	var name:String;
	var displayName:String;
	var icon:String;
	var difficulties:Array<String>;
	var folder:String;
	var weekName:String;
}

typedef OHSongStats =
{
	var score:Int;
	var accuracy:Float;
	var misses:Int;
}

/**
 * Shared helpers for the Other Halloween Psych port.
 */
class OHUtil
{
	// ---------- Text helpers ----------

	public static function makeText(x:Float, y:Float, w:Float, text:String, size:Int = 32, ?align:FlxTextAlign):FlxText
	{
		var t = new FlxText(x, y, w, text, size);
		t.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, align != null ? align : LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		t.borderSize = 2;
		t.antialiasing = ClientPrefs.data.antialiasing;
		return t;
	}

	public static function applyMarkup(text:FlxText, str:String, color:FlxColor = 0xFFFF4444):Void
	{
		if (text == null) return;
		try
		{
			text.applyMarkup(str, [new FlxTextFormatMarkerPair(new FlxTextFormat(color), "*")]);
		}
		catch (e:Dynamic)
		{
			text.text = str.split("*").join("");
		}
	}

	// ---------- VCR / shader helpers ----------

	public static function createVCR():FlxRuntimeShader
	{
		try
		{
			var frag = Paths.getTextFromFile('shaders/SimpleVCR.frag');
			if (frag == null || frag.length == 0)
				frag = DEFAULT_VCR_FRAG;
			var sh = new FlxRuntimeShader(frag);
			try { sh.setFloat('noisePercent', 0.35); } catch (_:Dynamic) {}
			try { sh.setFloat('iTime', 0); } catch (_:Dynamic) {}
			return sh;
		}
		catch (e:Dynamic)
		{
			trace("OHUtil.createVCR failed: " + e);
			return null;
		}
	}

	public static function setupVCR():FlxRuntimeShader
	{
		var sh = createVCR();
		if (sh != null)
		{
			try
			{
				FlxG.camera.setFilters([new ShaderFilter(sh)]);
			}
			catch (e:Dynamic) {}
		}
		return sh;
	}

	public static function tickVCR(sh:FlxRuntimeShader, time:Float):Void
	{
		if (sh == null) return;
		try { sh.setFloat('iTime', time); } catch (_:Dynamic) {}
	}

	// Minimal fallback VCR-ish noise shader
	static final DEFAULT_VCR_FRAG:String = "
		#pragma header
		uniform float iTime;
		uniform float noisePercent;
		float rand(vec2 co){
			return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
		}
		void main(){
			vec2 uv = openfl_TextureCoordv;
			vec4 col = flixel_texture2D(bitmap, uv);
			float n = rand(uv + iTime) * noisePercent;
			col.rgb += n * 0.15;
			gl_FragColor = col * openfl_Alphav;
		}
	";

	// ---------- Menu background ----------

	public static function makeMenuBG():FlxSprite
	{
		var bg = new FlxSprite(0, 0);
		var useSorrow = FlxG.random.bool(5);
		try
		{
			if (useSorrow)
			{
				bg.frames = Paths.getSparrowAtlas('menus/mainmenu/menusorrow');
				if (bg.frames != null)
					bg.animation.addByPrefix('idle', 'menusorrow idle', 24, true);
			}
			else
			{
				bg.frames = Paths.getSparrowAtlas('menus/mainmenu/maxshadow');
				if (bg.frames != null)
					bg.animation.addByPrefix('idle', 'maxshadow idle', 24, true);
			}
			if (bg.animation != null && bg.animation.getByName('idle') != null)
				bg.animation.play('idle');
		}
		catch (e:Dynamic)
		{
			bg.makeGraphic(FlxG.width, FlxG.height, 0xFF0a0a0c);
		}
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		bg.x += 500;
		bg.scrollFactor.set();
		return bg;
	}

	// ---------- State switching ----------

	public static function switchState(next:FlxState):Void
	{
		MusicBeatState.switchState(next);
	}

	// ---------- Song list / highscores ----------

	public static function loadSongList():Array<OHSongEntry>
	{
		var list:Array<OHSongEntry> = [];

		// Prefer freeplay song list if the mod provides one
		try
		{
			// Psych-style: scan weeks / freeplay
			#if MODS_ALLOWED
			// Keep simple – hard-coded known OH songs as safe default
			#end
		}
		catch (e:Dynamic) {}

		// Known Other Halloween songs (order matches original freeplay)
		var known = [
			{name: "game-on", display: "Game On", icon: "gbmax"},
			{name: "marriage-or-disparage", display: "Marriage or Disparage", icon: "limerence"},
			{name: "red", display: "RED", icon: "redboy"}
		];

		for (k in known)
		{
			list.push({
				name: k.name,
				displayName: k.display,
				icon: k.icon,
				difficulties: ["normal", "hard"],
				folder: "",
				weekName: ""
			});
		}

		// Future: enrich these entries (difficulties / icons / weekName) from the
		// week JSONs using WeekData.reloadWeekFiles(false) + WeekData.weeksLoaded.
		// (WeekData.reloadDirectory() does not exist in Psych Engine.)

		return list;
	}

	/**
	 * Chart / highscore file suffix for a difficulty name, matching Psych's
	 * convention: "normal" has no suffix, anything else is "-<name>".
	 * ("normal" -> "", "hard" -> "-hard")
	 */
	public static function getDifficultySuffix(diff:String):String
	{
		if (diff == null) return "";
		var d = StringTools.trim(diff.toLowerCase());
		return (d == "" || d == "normal") ? "" : "-" + d;
	}

	public static function getSongStats(songName:String, diff:String, ?weekName:String):OHSongStats
	{
		var result:OHSongStats = emptyStats();
		try
		{
			// Same key Psych's Highscore.formatSong() builds: song path + difficulty suffix.
			// We read the maps directly so this doesn't depend on whichever difficulty
			// list happens to be loaded in Difficulty.list, and doesn't create empty
			// 0-score entries in the save data the way Highscore.getScore() does.
			var key = Paths.formatToSongPath(songName) + getDifficultySuffix(diff);

			if (Highscore.songScores.exists(key))
				result.score = Highscore.songScores.get(key);

			// Psych stores accuracy as a 0..1 rating. Misses are not saved by Psych.
			if (Highscore.songRating.exists(key))
				result.accuracy = Highscore.songRating.get(key);
		}
		catch (e:Dynamic)
		{
			// Keep zeros
		}
		return result;
	}

	public static function emptyStats():OHSongStats
	{
		return {score: 0, accuracy: 0.0, misses: 0};
	}
}
