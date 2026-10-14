package substates;

import flixel.FlxSubState;

/**
 * Placeholder, the original OHGallery.hx was an empty create()/update() stub
 * (OHExtras still shows "NOT AVAILABLE YET" for the gallery).
 */
class OHGallery extends MusicBeatSubstate
{
	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) close(); // safety exit, the stub has no UI yet

		super.update(elapsed);
	}
}
