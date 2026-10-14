package other;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.Difficulty;
import backend.OHGlobal;
import backend.OHUtil;
import backend.OHUtil.OHSongEntry;
#if MODS_ALLOWED
import backend.Mods;
#end

import objects.HealthIcon;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

/**
 * Other Halloween freeplay – null-safe, VCR shader, locked songs, special transitions.
 */
class FreeplayState extends MusicBeatState
{
	public static var vocals:FlxSound = null;

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	var songs:Array<OHSongEntry> = [];
	var curSelected:Int = 0;
	var curDifficulty:Int = 0;
	var scoreText:FlxText;
	var canSelect:Bool = true;

	var vcr:FlxRuntimeShader;
	var INIT_X:Int = 100;
	var INIT_Y:Int = 150;

	var fpTitle:FlxText;
	var chapter:FlxText;
	var songName:FlxText;
	var needToUnlock:FlxText;

	var bg:FlxTypedGroup<FlxSprite>;
	var specialsBG:FlxSprite;
	var icons:FlxSpriteGroup;
	var iconScroll:Float = 0;
	var INIT_IS:Float = 0;
	var ICONSCROLL_FACTOR:Float = 150;

	var timer:FlxTimer;
	var pixelTimer:FlxTimer;
	var blackScreen:FlxSprite;
	var newDiffText:FlxText;
	var diffDesc:Array<String> = ["Normal", "Hard"];
	var lArrow:FlxText;
	var rArrow:FlxText;
	var lArrow2:FlxText;
	var rArrow2:FlxText;
	var minimaxEntrance:FlxSprite;

	var unlockableSongs:Array<String> = ['red'];
	var lockedSongs:Array<String> = [];
	var songsToUnlock:Map<String, Array<String>> = ['red' => ['game-on', 'marriage-or-disparage']];
	var looptime:Float = 0;

	var selecting:Bool = false;
	var transitioning:Bool = false;

	var daPixelZoom:Float = 6;
	var oldStageQuality:StageQuality;
	var pixellyCameras:Array<FlxCamera> = [];
	var pixellyShaders:Array<FlxRuntimeShader> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		oldStageQuality = FlxG.game.stage.quality;

		songs = [];
		WeekData.reloadWeekFiles(false); // Initializes the dynamic week loading

		for (i in 0...WeekData.weeksList.length)
		{
			var weekName:String = WeekData.weeksList[i];
			var leWeek:WeekData = WeekData.weeksLoaded.get(weekName);

			// Standard Psych Engine check to skip weeks explicitly hidden from Freeplay
			if (leWeek.hideFreeplay) continue;

			// Parse custom difficulties defined in the week JSON (or default to Easy/Normal/Hard)
			var diffs:Array<String> = ['Easy', 'Normal', 'Hard'];
			if (leWeek.difficulties != null && leWeek.difficulties.trim().length > 0)
			{
				diffs = [];
				for (diff in leWeek.difficulties.split(','))
				{
					diffs.push(diff.trim());
				}
			}

			// Loop through the songs defined in the current week's array
			for (songData in leWeek.songs)
			{
				// songData follows Psych's format: [Song Name, Icon Name, Color Array]
			var parsedName:String = Paths.formatToSongPath(songData[0]); 
		
				// Cast to OHSongEntry to match the expected typedef structure
				var newSong:OHSongEntry = cast {
					name: parsedName, // Formatted to match your lock arrays (e.g., 'game-on')
					icon: songData[1],
					folder: leWeek.folder == null ? '' : leWeek.folder,
					weekName: weekName,
					difficulties: diffs,
					displayName: songData[0] // Retains the raw JSON string for the UI display name
				};
		
				songs.push(newSong);
			}
		}

		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Freeplay != null
				&& OHGlobal.lang.languageTree.menus.Freeplay.diffDesc != null)
			{
				var d = OHGlobal.lang.languageTree.menus.Freeplay.diffDesc;
				diffDesc = [];
				if (d.normal != null) diffDesc.push(d.normal); else diffDesc.push("Normal");
				if (d.hard != null) diffDesc.push(d.hard); else diffDesc.push("Hard");
			}
		}
		catch (e:Dynamic) {}

		specialsBG = new FlxSprite(0, 0);
		try { specialsBG.loadGraphic(Paths.image('menus/freeplay/songBG/specials')); }
		catch (e:Dynamic) { specialsBG.makeGraphic(400, 400, 0xFF333333); }
		specialsBG.antialiasing = ClientPrefs.data.antialiasing;
		specialsBG.scale.set(0.8, 0.8);
		specialsBG.updateHitbox();
		specialsBG.x = FlxG.width - specialsBG.width;
		specialsBG.screenCenter(Y);
		add(specialsBG);

		bg = new FlxTypedGroup<FlxSprite>();
		icons = new FlxSpriteGroup();
		add(bg);

		var iconX:Float = 0;
		for (i in 0...songs.length)
		{
			var song = songs[i];
			if (song == null) continue;

			var icon = new HealthIcon(song.icon != null ? song.icon : 'face');
			icon.updateHitbox();
			icon.ID = i;
			icon.x = (i > 0) ? (iconX += icon.width) : 0;

			if (unlockableSongs.contains(song.name))
			{
				var unlockList = songsToUnlock.get(song.name);
				if (unlockList != null && unlockList.length >= 2)
				{
					var d1 = OHUtil.getSongStats(unlockList[0], 'normal');
					var d2 = OHUtil.getSongStats(unlockList[1], 'normal');
					if ((d1 == null || d1.score <= 0) && (d2 == null || d2.score <= 0))
					{
						icon.color = FlxColor.BLACK;
						lockedSongs.push(song.name);
					}
				}
			}
			icons.add(icon);

			if (!Paths.fileExists('images/menus/freeplay/songBG/' + song.name + '.png', IMAGE)) continue;
			var curBG = new FlxSprite(0, 0);
			try { curBG.loadGraphic(Paths.image('menus/freeplay/songBG/' + song.name)); }
			catch (e:Dynamic) { continue; }
			curBG.antialiasing = ClientPrefs.data.antialiasing;
			curBG.scale.set(0.8, 0.8);
			curBG.updateHitbox();
			curBG.x = FlxG.width - curBG.width;
			curBG.screenCenter(Y);
			curBG.ID = i;
			curBG.alpha = 0;
			bg.add(curBG);
		}

		var frame = new FlxSprite(0, 0);
		try { frame.loadGraphic(Paths.image('menus/freeplay/free_template')); }
		catch (e:Dynamic) { frame.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT); }
		frame.antialiasing = ClientPrefs.data.antialiasing;
		add(frame);

		fpTitle = OHUtil.makeText(0, 10, 0, "FREEPLAY", 90);
		fpTitle.screenCenter(X);

		var _scoreText = OHUtil.makeText(INIT_X, INIT_Y, 0, "ACCURACY:", 40);
		_scoreText.color = FlxColor.RED;
		scoreText = OHUtil.makeText(INIT_X, _scoreText.y + 40, 0, "-%", 40);

		var _chapter = OHUtil.makeText(INIT_X, scoreText.y + 60, 0, "THEME:", 40);
		_chapter.color = FlxColor.RED;
		chapter = OHUtil.makeText(INIT_X, _chapter.y + 40, 0, "", 40);

		var _songName = OHUtil.makeText(INIT_X, chapter.y + 60, 0, "SONG:", 40);
		_songName.color = FlxColor.RED;
		songName = OHUtil.makeText(INIT_X, _songName.y + 40, 0, "", 40);

		for (spr in [fpTitle, _scoreText, scoreText, _chapter, chapter, _songName, songName])
			add(spr);

		add(icons);
		icons.y = 550;
		if (icons.members.length > 0 && icons.members[0] != null)
			icons.x = (FlxG.width / 2) - (icons.members[0].width / 2);
		else
			icons.x = FlxG.width / 2;
		INIT_IS = icons.x;
		iconScroll = INIT_IS;

		lArrow = OHUtil.makeText(fpTitle.x - 45, 600, 0, '< [', 90);
		lArrow.scrollFactor.set();
		lArrow.updateHitbox();
		add(lArrow);

		rArrow = OHUtil.makeText(fpTitle.x + fpTitle.width - 150, 600, 0, '] >', 90);
		rArrow.scrollFactor.set();
		rArrow.updateHitbox();
		add(rArrow);

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0;
		add(blackScreen);

		newDiffText = OHUtil.makeText(0, 0, 0, "", 90);
		newDiffText.scrollFactor.set();
		newDiffText.screenCenter();
		newDiffText.visible = false;
		add(newDiffText);

		lArrow2 = OHUtil.makeText(newDiffText.x - 100, newDiffText.y, 0, '<', 90);
		lArrow2.scrollFactor.set();
		lArrow2.updateHitbox();
		lArrow2.visible = false;
		add(lArrow2);

		rArrow2 = OHUtil.makeText(newDiffText.x + newDiffText.width + 50, newDiffText.y, 0, '>', 90);
		rArrow2.scrollFactor.set();
		rArrow2.updateHitbox();
		rArrow2.visible = false;
		add(rArrow2);

		needToUnlock = OHUtil.makeText(0, 0, 700, '', 42);
		needToUnlock.scrollFactor.set();
		needToUnlock.screenCenter();
		needToUnlock.x += 200;
		needToUnlock.y -= 100;
		needToUnlock.color = FlxColor.RED;
		add(needToUnlock);

		minimaxEntrance = new FlxSprite(0, 0);
		try
		{
			minimaxEntrance.frames = Paths.getSparrowAtlas('menus/freeplay/minitrans');
			if (minimaxEntrance.frames != null)
				minimaxEntrance.animation.addByPrefix('idle', 'minitrans idle', 30, false);
		}
		catch (e:Dynamic)
		{
			minimaxEntrance.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		}
		minimaxEntrance.antialiasing = ClientPrefs.data.antialiasing;
		minimaxEntrance.updateHitbox();
		minimaxEntrance.visible = false;
		add(minimaxEntrance);

		vcr = OHUtil.setupVCR();

		if (songs.length > 0)
		{
			changeSelection(0, true);
			changeDiff(0);
		}

		super.create();
		scareTransition();
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		var pixelZoom = 1 / daPixelZoom / Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
		for (e in pixellyCameras)
		{
			if (e == null || !e.exists) continue;
			e.zoom = pixelZoom;
		}
		for (e in pixellyShaders)
		{
			if (e == null) continue;
			try { e.setFloat('pixelZoom', pixelZoom); } catch (_:Dynamic) {}
		}

		icons.x = FlxMath.lerp(iconScroll, icons.x, Math.exp(-elapsed * 6.3));

		if (!transitioning) handleInput();
		super.update(elapsed);
	}

	function handleInput()
	{
		if (songs.length == 0) return;

		if (canSelect)
			changeSelection((controls.UI_LEFT_P ? -1 : 0) + (controls.UI_RIGHT_P ? 1 : 0));

		if (selecting)
			changeDiff((controls.UI_LEFT_P ? -1 : 0) + (controls.UI_RIGHT_P ? 1 : 0));

		if (controls.BACK)
		{
			if (selecting)
			{
				closeDifficultySelect();
				canSelect = true;
			}
			else
				OHUtil.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (selecting)
			{
				closeDifficultySelect();
				selectSong();
			}
			else
			{
				if (curSelected < 0 || curSelected >= songs.length) return;
				if (lockedSongs.contains(songs[curSelected].name)) return;
				newDiffText.visible = true;
				lArrow2.visible = true;
				rArrow2.visible = true;
				blackScreen.alpha = 0.7;
				selecting = true;
				canSelect = false;
			}
		}
	}

	function closeDifficultySelect()
	{
		newDiffText.visible = false;
		lArrow2.visible = false;
		rArrow2.visible = false;
		blackScreen.alpha = 0;
		selecting = false;
	}

	function changeSelection(change:Int = 0, force:Bool = false)
	{
		if (songs.length == 0) return;
		if (change == 0 && !force) return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);
		if (songs[curSelected] != null && curDifficulty >= songs[curSelected].difficulties.length)
			curDifficulty = 0;

		changeBG();
		changeInfo();
		changeIcon(change, force);
		try { FlxG.sound.play(Paths.sound('menu/scroll'), 0.7); } catch (_:Dynamic) {}
	}

	function changeDiff(change:Int = 0)
	{
		if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) return;
		var curSong = songs[curSelected];
		if (curSong == null || curSong.difficulties == null || curSong.difficulties.length == 0) return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, curSong.difficulties.length - 1);
		newDiffText.text = curSong.difficulties[curDifficulty];
		newDiffText.screenCenter(X);
		lArrow2.setPosition(newDiffText.x - 100, newDiffText.y);
		rArrow2.setPosition(newDiffText.x + newDiffText.width + 50, newDiffText.y);
	}

	function selectSong()
	{
		if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) return;

		canSelect = false;
		transitioning = true;
		if (FlxG.sound.music != null) FlxG.sound.music.pause();

		var songName = songs[curSelected].name;
		switch (songName)
		{
			case 'game-on':
				vcr = null;
				try { FlxG.sound.play(Paths.sound('menu/av_accept'), 1); } catch (_:Dynamic) {}
				FlxG.camera.pixelPerfectRender = true;
				FlxG.camera.antialiasing = false;
				makeCameraPixely(FlxG.camera);
				FlxG.camera.flash(FlxColor.fromString('#e6fad8'), 0.7);
				pixelTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					if (tmr.loops > 2) blackScreen.alpha += 0.25;
				}, 6);
				timer = new FlxTimer().start(6, function(_) enterSong());
			case 'marriage-or-disparage':
				try { FlxG.sound.play(Paths.sound('menu/marriage_access'), 1); } catch (_:Dynamic) {}
				FlxG.camera.flash(FlxColor.MAGENTA, 0.7);
				FlxTween.tween(blackScreen, {alpha: 1}, 5);
				timer = new FlxTimer().start(6, function(_) enterSong());
			case 'red':
				minimaxEntrance.visible = true;
				if (minimaxEntrance.animation != null && minimaxEntrance.animation.getByName('idle') != null)
					minimaxEntrance.animation.play('idle', true);
				try { FlxG.sound.play(Paths.sound('menu/minitrans')); } catch (_:Dynamic) {}
				timer = new FlxTimer().start(3, function(_) enterSong());
			default:
				try { FlxG.sound.play(Paths.sound('menu/confirm'), 1); } catch (_:Dynamic) {}
				FlxTween.tween(blackScreen, {alpha: 1}, 1);
				timer = new FlxTimer().start(1, function(_) enterSong());
		}
	}

	function enterSong()
	{
		if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) return;
		var song = songs[curSelected];
		if (song == null || song.difficulties == null || song.difficulties.length <= 0) return;

		#if MODS_ALLOWED
		Mods.currentModDirectory = song.folder != null ? song.folder : '';
		#end
		if (song.weekName != null && WeekData.weeksLoaded.exists(song.weekName))
			Difficulty.loadFromWeek(WeekData.weeksLoaded.get(song.weekName));

		var songLower = Paths.formatToSongPath(song.name);
		var poop = Highscore.formatSong(songLower, curDifficulty);

		try
		{
			PlayState.SONG = Song.loadFromJson(poop, songLower);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			if (FlxG.sound.music != null) FlxG.sound.music.volume = 0;
			LoadingState.loadAndSwitchState(new PlayState());
		}
		catch (e:Dynamic)
		{
			trace("ERROR LOADING: " + e);
			try { FlxG.sound.play(Paths.sound('cancelMenu')); } catch (_:Dynamic) {}
			transitioning = false;
			canSelect = true;
			blackScreen.alpha = 0;
		}
	}

	function scareTransition()
	{
		FlxG.camera.flash(FlxColor.WHITE, 0.5);
		try { FlxG.sound.play(Paths.sound('menu/Terror 1'), 1); } catch (_:Dynamic) {}
		try { FlxG.sound.playMusic(Paths.music('menus/main_menu'), 1); } catch (_:Dynamic) {}
	}

	function makeCameraPixely(cam:FlxCamera)
	{
		if (cam == null) return;
		cam.pixelPerfectRender = true;
		cam.zoom /= Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y) * daPixelZoom;

		var shad:FlxRuntimeShader = null;
		try
		{
			shad = new FlxRuntimeShader(Paths.getTextFromFile('shaders/pixelZoomShader.frag'));
			cam.setFilters([new ShaderFilter(shad)]);
		}
		catch (e:Dynamic) {}

		pixellyCameras.push(cam);
		if (shad != null) pixellyShaders.push(shad);
		FlxG.game.stage.quality = StageQuality.LOW;
	}

	function changeInfo()
	{
		if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) return;
		var song = songs[curSelected];
		if (song == null) return;

		var diffName = (song.difficulties != null && song.difficulties.length > 0)
			? song.difficulties[curDifficulty] : 'normal';
		var data = OHUtil.getSongStats(song.name, diffName, song.weekName);
		scoreText.text = (data != null) ? (Math.round(data.accuracy * 100) + "%") : "-%";

		switch (song.name)
		{
			case 'game-on': chapter.text = "CHAPTER 1";
			case 'marriage-or-disparage': chapter.text = "CHAPTER 2";
			default:
				chapter.text = (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr') ? "DESC" : "UKNW";
		}

		if (lockedSongs.contains(song.name))
		{
			songName.text = '???';
			var unlockList = songsToUnlock.get(song.name);
			var listStr = (unlockList != null) ? unlockList.join('\n') : '';
			if (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr')
				needToUnlock.text = 'BLOQUEADO\nCompleta estas canciones para desbloquearlo:\n' + listStr;
			else
				needToUnlock.text = 'LOCKED SONG\nComplete these songs to unlock it:\n' + listStr;
		}
		else
		{
			songName.text = (song.displayName != null) ? song.displayName : song.name;
			needToUnlock.text = '';
		}
	}

	function changeBG()
	{
		if (bg == null) return;
		bg.forEach(function(spr:FlxSprite)
		{
			FlxTween.cancelTweensOf(spr);
			FlxTween.tween(spr, {alpha: 0}, 0.05, {ease: FlxEase.circIn});
			if (spr.ID == curSelected)
				FlxTween.tween(spr, {alpha: 1}, 0.05, {ease: FlxEase.circOut, startDelay: 0.05});
		});
	}

	function changeIcon(change:Int = 0, force:Bool = false)
	{
		if (icons == null || icons.members.length == 0) return;
		if (curSelected < 0 || curSelected >= icons.members.length) return;

		if ((change == 0 && force) || curSelected == 0)
		{
			if (icons.members[curSelected] != null)
				iconScroll = (FlxG.width / 2) - (icons.members[curSelected].width / 2 * (curSelected + 1));
		}
		else if (curSelected == songs.length - 1)
			iconScroll = INIT_IS - (ICONSCROLL_FACTOR * curSelected);
		else
			iconScroll -= ICONSCROLL_FACTOR * change;

		icons.forEach(function(spr:FlxSprite)
		{
			spr.alpha = (spr.ID == curSelected) ? 1 : 0.6;
		});
	}

	override function destroy()
	{
		FlxG.game.stage.quality = oldStageQuality;
		super.destroy();
	}
}
