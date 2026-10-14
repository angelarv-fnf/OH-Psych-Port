package other;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

/**
 * Other Halloween - Credits (Psych 0.7.3 port)
 */
class OHCreditsState extends MusicBeatState
{
	var credits:Array<Array<String>> = [
		['OTHER HALLOWEEN'],
		['EstudiOmega', 'Director'],
		['Sexy Team', 'Mod Team'],
		[''],
		['ORIGINAL'],
		['Funkin\' Crew', 'Friday Night Funkin\''],
		['YoshiCrafter29', 'Codename Engine'],
		[''],
		['PSYCH ENGINE'],
		['Shadow Mario', 'Psych Engine'],
		['Riveren', 'Artist / Animator'],
		[''],
		['SPECIAL THANKS'],
		['DaFuq!?Boom!', 'Inspiration'],
		['You', 'For playing']
	];

	var grpTexts:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var selectable:Array<Int> = [];

	override function create()
	{
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF0a0a0c);
		add(bg);

		var title = new FlxText(0, 30, FlxG.width, "CREDITS", 42);
		title.setFormat(Paths.font("vcr.ttf"), 42, 0xFFFF4444, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.borderSize = 3;
		add(title);

		grpTexts = new FlxTypedGroup<FlxText>();
		add(grpTexts);

		for (i in 0...credits.length)
		{
			var isHeader = credits[i].length == 1;
			var label = isHeader ? credits[i][0] : credits[i][0] + "  -  " + credits[i][1];
			var size = isHeader ? 32 : 24;
			var col = isHeader ? 0xFFFF6666 : FlxColor.WHITE;

			var t = new FlxText(0, 120 + (i * 40), FlxG.width, label, size);
			t.setFormat(Paths.font("vcr.ttf"), size, col, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.borderSize = 2;
			t.ID = i;
			grpTexts.add(t);

			if (!isHeader && credits[i][0] != '')
				selectable.push(i);
		}

		var hint = new FlxText(0, FlxG.height - 40, FlxG.width, "ESC = Back", 16);
		hint.setFormat(Paths.font("vcr.ttf"), 16, 0xFF888888, CENTER);
		add(hint);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
