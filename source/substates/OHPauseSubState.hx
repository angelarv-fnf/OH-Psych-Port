package substates;

import backend.OHGlobal;
import backend.OHUtil;
import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;
import other.MainMenuState;
import other.FreeplayState as OHFreeplayState;

/**
 * Other Halloween custom pause.
 * Text-based menu with optional VCR feel.
 * For "game-on" it can fall back to a simpler / pixel-friendly layout.
 */
class OHPauseSubState extends MusicBeatSubstate
{
	var optionShit:Array<String> = ["Resume", "Restart", "Options", "Exit"];
	var texts:FlxTypedGroup<FlxText>;
	var arrow:FlxText;
	var fade:FlxSprite;

	var INIT_X:Int = 140;
	var INIT_Y:Int = 120;
	var OFFSET:Int = 140;

	var curSelected:Int = 0;
	var camPause:FlxCamera;
	var looptime:Float = 0;
	var vcr:FlxRuntimeShader;

	var isGameOn:Bool = false;

	override function create()
	{
		// Detect game-on for possible special handling
		try
		{
			if (PlayState.SONG != null && PlayState.SONG.song != null)
				isGameOn = (Paths.formatToSongPath(PlayState.SONG.song) == 'game-on');
		}
		catch (e:Dynamic) {}

		// Language override
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Pause != null
				&& OHGlobal.lang.languageTree.menus.Pause.optionShit != null)
			{
				optionShit = OHGlobal.lang.languageTree.menus.Pause.optionShit;
			}
		}
		catch (e:Dynamic) {}

		camPause = new FlxCamera();
		camPause.bgColor = 0;
		FlxG.cameras.add(camPause, false);

		fade = new FlxSprite();
		try
		{
			fade.loadGraphic(Paths.image('game/pause/pause_fade'));
		}
		catch (e:Dynamic)
		{
			fade.makeGraphic(Std.int(FlxG.width * 0.55), FlxG.height, 0xCC000000);
		}
		fade.scrollFactor.set();
		fade.screenCenter(Y);
		fade.x = -fade.width * 0.15;
		fade.cameras = [camPause];
		add(fade);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);

		var c:Int = 0;
		for (i in optionShit)
		{
			var text = OHUtil.makeText(INIT_X, INIT_Y + (c * OFFSET), 0, i.toUpperCase(), 80);
			text.cameras = [camPause];
			text.ID = c;
			text.updateHitbox();
			text.scrollFactor.set();
			texts.add(text);
			c++;
		}

		arrow = OHUtil.makeText(INIT_X - 60, INIT_Y, 0, '>', 90);
		arrow.cameras = [camPause];
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		texts.add(arrow);

		// Soft VCR on the pause camera
		vcr = OHUtil.createVCR();
		if (vcr != null)
		{
			try
			{
				camPause.setFilters([new openfl.filters.ShaderFilter(vcr)]);
			}
			catch (e:Dynamic) {}
		}

		changeItem();
		cameras = [camPause];

		// Optional: update Discord presence
		try
		{
			#if DISCORD_ALLOWED
			// DiscordClient.changePresence(...) if desired
			#end
		}
		catch (e:Dynamic) {}

		super.create();
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		if (texts != null && texts.members.length > 0
			&& curSelected >= 0 && curSelected < texts.members.length
			&& texts.members[curSelected] != null)
		{
			arrow.y = texts.members[curSelected].y;
		}

		if (controls.UI_UP_P) changeItem(-1);
		if (controls.UI_DOWN_P) changeItem(1);
		if (controls.ACCEPT) select();
		if (controls.BACK)
		{
			close();
			return;
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (optionShit == null || optionShit.length == 0) return;
		curSelected = FlxMath.wrap(curSelected + huh, 0, optionShit.length - 1);
		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function select()
	{
		switch (curSelected)
		{
			case 0: // Resume
				close();
			case 1: // Restart
				restartSong();
			case 2: // Options
				PlayState.instance.paused = true;
				if (PlayState.instance.vocals != null)
					PlayState.instance.vocals.volume = 0;
				MusicBeatState.switchState(new OptionsState());
				OptionsState.onPlayState = true;
			case 3: // Exit
				exitToMenu();
		}
	}

	function restartSong()
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		if (PlayState.instance.vocals != null)
			PlayState.instance.vocals.volume = 0;
		MusicBeatState.resetState();
	}

	function exitToMenu()
	{
		#if DISCORD_ALLOWED
		try { DiscordClient.resetClientID(); } catch (_:Dynamic) {}
		#end
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		PlayState.changedDifficulty = false;
		PlayState.chartingMode = false;

		Mods.loadTopMod();

		// Prefer OH freeplay / main menu
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new other.StoryMenuState());
		else
			MusicBeatState.switchState(new OHFreeplayState());

		try { FlxG.sound.playMusic(Paths.music('menus/main_menu')); }
		catch (e:Dynamic)
		{
			try { FlxG.sound.playMusic(Paths.music('freakyMenu')); } catch (_:Dynamic) {}
		}
	}

	override function destroy()
	{
		if (FlxG.cameras.list.contains(camPause))
			FlxG.cameras.remove(camPause, true);
		super.destroy();
	}
}
