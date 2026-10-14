package substates;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;

import objects.Character;
import states.PlayState;
import other.FreeplayState as OHFreeplayState;
import other.StoryMenuState;

#if VIDEOS_ALLOWED
import hxcodec.flixel.FlxVideo;
#end

/**
 * Other Halloween game over.
 * - Default: normal BF death animation (Psych style).
 * - For "marriage-or-disparage": plays a video (gore / no-gore) + timed subtitles
 *   based on explicitMode, then shows a "Retry?" prompt.
 */
class OHGameOverSubstate extends MusicBeatSubstate
{
	public static var instance:OHGameOverSubstate;

	// Vanilla-style fields
	public var boyfriend:Character;
	var camFollow:FlxObject;
	var moveCamera:Bool = false;
	var playingDeathSound:Bool = false;
	var startedDeath:Bool = false;
	var isEnding:Bool = false;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	// MoD video path
	var isMoD:Bool = false;
	var useVideo:Bool = false;
	var videoFinished:Bool = false;
	var gore:Bool = false;

	var screenCamera:FlxCamera;
	var videoCamera:FlxCamera;
	var retry:FlxText;
	var subtitles:FlxText;
	var videoSubs:Array<String> = [];
	var subsTimers:Array<FlxTimer> = [];

	#if VIDEOS_ALLOWED
	var video:FlxVideo;
	#end

	public static function resetVariables()
	{
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';

		var _song = PlayState.SONG;
		if (_song != null)
		{
			if (_song.gameOverChar != null && _song.gameOverChar.trim().length > 0)
				characterName = _song.gameOverChar;
			if (_song.gameOverSound != null && _song.gameOverSound.trim().length > 0)
				deathSoundName = _song.gameOverSound;
			if (_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0)
				loopSoundName = _song.gameOverLoop;
			if (_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0)
				endSoundName = _song.gameOverEnd;
		}
	}

	override function create()
	{
		instance = this;
		Conductor.songPosition = 0;

		// Detect Marriage or Disparage
		try
		{
			if (PlayState.SONG != null && PlayState.SONG.song != null)
			{
				var s = Paths.formatToSongPath(PlayState.SONG.song);
				isMoD = (s == 'marriage-or-disparage' || s == 'marriageordisparage');
			}
		}
		catch (e:Dynamic) {}

		gore = OHGlobal.explicitMode;
		useVideo = isMoD;

		// Load subtitle lines
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.subtitles != null
				&& OHGlobal.lang.languageTree.subtitles.MoD_gameover != null)
			{
				var node = OHGlobal.lang.languageTree.subtitles.MoD_gameover;
				videoSubs = gore
					? (node.gore != null ? node.gore : [])
					: (node.nogore != null ? node.nogore : []);
			}
		}
		catch (e:Dynamic) {}

		if (useVideo)
			createVideoGameOver();
		else
			createVanillaGameOver();

		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		super.create();
	}

	function createVanillaGameOver()
	{
		boyfriend = new Character(
			PlayState.instance.boyfriend.getScreenPosition().x,
			PlayState.instance.boyfriend.getScreenPosition().y,
			characterName, true);
		boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
		add(boyfriend);

		FlxG.sound.play(Paths.sound(deathSoundName));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		boyfriend.playAnim('firstDeath');

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(
			boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0],
			boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
		FlxG.camera.focusOn(new FlxPoint(
			FlxG.camera.scroll.x + (FlxG.camera.width / 2),
			FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
		add(camFollow);
	}

	function createVideoGameOver()
	{
		// Cameras
		screenCamera = new FlxCamera();
		screenCamera.bgColor = 0;
		FlxG.cameras.add(screenCamera, false);

		videoCamera = new FlxCamera();
		videoCamera.bgColor = 0;
		FlxG.cameras.add(videoCamera, false);

		retry = OHUtil.makeText(0, 500, 0, "Retry?", 90);
		retry.scrollFactor.set();
		retry.screenCenter(X);
		retry.alpha = 0;
		retry.cameras = [screenCamera];
		add(retry);

		subtitles = OHUtil.makeText(0, 600, FlxG.width - 40, "", 36, CENTER);
		subtitles.screenCenter(X);
		subtitles.cameras = [videoCamera];
		add(subtitles);

		#if VIDEOS_ALLOWED
		var videoName = gore ? 'game_over_gore' : 'Maxi_te_lo_explica';
		var videoPath = Paths.video(videoName); // expects assets/videos/...

		video = new FlxVideo();
		video.onEndReached.add(onVideoEnd);
		try
		{
			video.play(videoPath);
			// Note: hxCodec / hxvlc APIs differ slightly across Psych versions.
			// Adjust play() / bitmap handling if your hxCodec version requires it.
		}
		catch (e:Dynamic)
		{
			trace("OHGameOver: video failed to play -> " + e);
			// Fallback to vanilla
			useVideo = false;
			createVanillaGameOver();
			return;
		}
		#else
		// No video support – fall back
		useVideo = false;
		createVanillaGameOver();
		return;
		#end

		// Timed subtitles
		scheduleSubtitles();
	}

	function scheduleSubtitles()
	{
		// Clear old
		for (t in subsTimers)
			if (t != null && t.active) t.cancel();
		subsTimers = [];

		if (gore)
		{
			// Example timings from original
			subsTimers.push(new FlxTimer().start(7.5, function(_)
			{
				if (videoSubs.length > 0) {
					subtitles.text = videoSubs[0];
					subtitles.screenCenter(X);
				}
			}));
			subsTimers.push(new FlxTimer().start(9.5, function(_)
			{
				subtitles.text = "";
			}));
		}
		else
		{
			if (videoSubs.length > 0)
			{
				subsTimers.push(new FlxTimer().start(0.1, function(_)
				{
					subtitles.text = videoSubs[0];
					subtitles.screenCenter(X);
				}));
				subsTimers.push(new FlxTimer().start(3.5, function(_)
				{
					subtitles.text = "";
				}));
			}
			if (videoSubs.length > 1)
			{
				subsTimers.push(new FlxTimer().start(3.8, function(_)
				{
					subtitles.text = videoSubs[1];
					subtitles.screenCenter(X);
				}));
				subsTimers.push(new FlxTimer().start(5.0, function(_)
				{
					subtitles.text = "";
				}));
			}
		}
	}

	function onVideoEnd()
	{
		videoFinished = true;
		for (t in subsTimers)
			if (t != null && t.active) t.cancel();

		#if VIDEOS_ALLOWED
		if (video != null)
		{
			try { video.dispose(); } catch (_:Dynamic) {}
			video = null;
		}
		#end
		if (videoCamera != null)
			videoCamera.visible = false;

		// Show Retry prompt
		retry.angle = -3;
		FlxTween.tween(retry, {alpha: 1}, 1);
		FlxTween.tween(retry, {angle: 3}, 2.6, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
		FlxTween.tween(retry, {y: retry.y - 30}, 1, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		if (useVideo)
		{
			if (!videoFinished)
			{
				// Allow skip
				if (controls.ACCEPT)
					forceEndVideo();
			}
			else
			{
				if (controls.ACCEPT)
					endBullshit();
				if (controls.BACK)
					exitToMenu();
			}
		}
		else
		{
			// Vanilla path
			if (controls.ACCEPT)
				endBullshit();

			if (controls.BACK)
				exitToMenu();

			if (boyfriend != null && boyfriend.animation.curAnim != null)
			{
				if (boyfriend.animation.curAnim.name == 'firstDeath' && boyfriend.animation.curAnim.finished && startedDeath)
					boyfriend.playAnim('deathLoop');

				if (boyfriend.animation.curAnim.name == 'firstDeath')
				{
					if (boyfriend.animation.curAnim.curFrame >= 12 && !moveCamera)
					{
						FlxG.camera.follow(camFollow, LOCKON, 0.6);
						moveCamera = true;
					}
					if (boyfriend.animation.curAnim.finished && !playingDeathSound)
					{
						startedDeath = true;
						coolStartDeath();
					}
				}
			}

			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				Conductor.songPosition = FlxG.sound.music.time;
		}

		PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	function forceEndVideo()
	{
		#if VIDEOS_ALLOWED
		if (video != null)
		{
			try { video.stop(); } catch (_:Dynamic) {}
		}
		#end
		onVideoEnd();
	}

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (isEnding) return;
		isEnding = true;

		if (useVideo)
		{
			// Magenta flash + sound then restart
			try { FlxG.sound.play(Paths.sound('menu/marriage_access'), 1); } catch (_:Dynamic) {}
			if (screenCamera != null)
				screenCamera.flash(FlxColor.MAGENTA, 0.7);

			FlxTween.cancelTweensOf(retry);
			FlxTween.tween(retry, {alpha: 0, angle: retry.angle - 20, "scale.x": 0.4, "scale.y": 0.4}, 1.5, {ease: FlxEase.sineIn});

			new FlxTimer().start(0.7, function(_)
			{
				if (screenCamera != null)
					screenCamera.fade(FlxColor.BLACK, 1.5, false, function()
					{
						MusicBeatState.resetState();
					});
				else
					MusicBeatState.resetState();
			});
		}
		else
		{
			if (boyfriend != null)
				boyfriend.playAnim('deathConfirm', true);
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
		}

		PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
	}

	function exitToMenu()
	{
		#if DISCORD_ALLOWED
		try { DiscordClient.resetClientID(); } catch (_:Dynamic) {}
		#end
		if (FlxG.sound.music != null) FlxG.sound.music.stop();
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		PlayState.chartingMode = false;

		Mods.loadTopMod();
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new other.StoryMenuState());
		else
			MusicBeatState.switchState(new OHFreeplayState());

		try { FlxG.sound.playMusic(Paths.music('menus/main_menu')); }
		catch (e:Dynamic)
		{
			try { FlxG.sound.playMusic(Paths.music('freakyMenu')); } catch (_:Dynamic) {}
		}

		PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
	}

	override function destroy()
	{
		instance = null;
		for (t in subsTimers)
			if (t != null && t.active) t.cancel();

		#if VIDEOS_ALLOWED
		if (video != null)
		{
			try { video.dispose(); } catch (_:Dynamic) {}
			video = null;
		}
		#end

		if (screenCamera != null && FlxG.cameras.list.contains(screenCamera))
			FlxG.cameras.remove(screenCamera, true);
		if (videoCamera != null && FlxG.cameras.list.contains(videoCamera))
			FlxG.cameras.remove(videoCamera, true);

		super.destroy();
	}
}
