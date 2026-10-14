package other;

import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Gallery placeholder – original was an empty stub.
 * Shows a clear "NOT AVAILABLE YET" message and lets the player exit.
 */
class OHGallery extends MusicBeatSubstate
{
	override function create()
	{
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xCC000000);
		add(bg);

		var title = OHUtil.makeText(0, FlxG.height / 2 - 60, FlxG.width, "GALLERY", 48, CENTER);
		title.color = 0xFFFF4444;
		add(title);

		var msg = OHUtil.makeText(0, title.y + 70, FlxG.width, "NOT AVAILABLE YET", 32, CENTER);
		msg.color = FlxColor.WHITE;
		add(msg);

		var hint = OHUtil.makeText(0, FlxG.height - 50, FlxG.width, "Press ESC / BACK to return", 18, CENTER);
		hint.color = 0xFF888888;
		add(hint);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			close();
			return;
		}
		super.update(elapsed);
	}
}
