package other;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

/**
 * Other Halloween - Extras hub (Psych 0.7.3 port)
 * Links to Stats / Otherpedia placeholders / Gallery
 */
class OHExtrasState extends MusicBeatState
{
	var options:Array<String> = ['stats', 'otherpedia', 'gallery', 'back'];
	var menuItems:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var selectedSomethin:Bool = false;

	override function create()
	{
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF0a0a0c);
		add(bg);

		var title = new FlxText(0, 40, FlxG.width, "EXTRAS", 42);
		title.setFormat(Paths.font("vcr.ttf"), 42, 0xFFFF4444, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.borderSize = 3;
		add(title);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...options.length)
		{
			var t = new FlxText(0, 180 + (i * 80), FlxG.width, options[i].toUpperCase(), 36);
			t.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.borderSize = 2;
			t.ID = i;
			t.alpha = 0.6;
			menuItems.add(t);
		}

		var hint = new FlxText(0, FlxG.height - 40, FlxG.width, "Some extras are placeholders in this port", 16);
		hint.setFormat(Paths.font("vcr.ttf"), 16, 0xFF666666, CENTER);
		add(hint);

		changeItem();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P) { FlxG.sound.play(Paths.sound('scrollMenu'), 0.4); changeItem(-1); }
			if (controls.UI_DOWN_P) { FlxG.sound.play(Paths.sound('scrollMenu'), 0.4); changeItem(1); }
			if (controls.BACK || (controls.ACCEPT && options[curSelected] == 'back'))
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
			else if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				// Placeholders for now – return to menu after a beat
				new FlxTimer().start(0.5, function(_) {
					selectedSomethin = false;
					// Could open OHStats / Otherpedia later
				});
			}
		}
		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		curSelected = (curSelected + change + options.length) % options.length;
		for (i in 0...menuItems.length)
		{
			menuItems.members[i].alpha = (i == curSelected) ? 1 : 0.55;
			menuItems.members[i].color = (i == curSelected) ? 0xFFFF8888 : FlxColor.WHITE;
		}
	}
}
