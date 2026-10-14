package other;

import flixel.FlxG;

/**
 * Other Halloween has no story mode.
 * Stub so Psych files that still reference StoryMenuState keep compiling.
 * Immediately returns to the main menu.
 */
class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	override function create()
	{
		super.create();
		MusicBeatState.switchState(new MainMenuState());
	}
}
