package other;

import backend.OHGlobal;
import backend.OHUtil;
import backend.OHUtil.OHSongEntry;
import backend.OHUtil.OHSongStats;

import objects.HealthIcon;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

class OHStats extends MusicBeatSubstate
{
	var songs:Array<OHSongEntry> = [];
	var curSelected:Int = 0;

	var icons:FlxTypedGroup<HealthIcon>;
	var songNames:FlxTypedGroup<FlxText>;
	var scoreView:FlxTypedGroup<FlxText>;
	var arrow:FlxText;

	var INIT_X:Int = 800;
	var INIT_Y:Int = 200;

	override function create()
	{
		super.create();

		var accuLabel:String = "ACCURACY";
		var comboLabel:String = "SCORE";
		var missesLabel:String = "MISSES";
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Extras != null
				&& OHGlobal.lang.languageTree.menus.Extras.stats != null)
			{
				var s = OHGlobal.lang.languageTree.menus.Extras.stats;
				if (s.accu != null) accuLabel = s.accu;
				if (s.combo != null) comboLabel = s.combo;
				if (s.misses != null) missesLabel = s.misses;
			}
		}
		catch (e:Dynamic) {}

		try { songs = OHUtil.loadSongList(); } catch (e:Dynamic) { songs = []; }
		if (songs == null) songs = [];

		icons = new FlxTypedGroup<HealthIcon>();
		scoreView = new FlxTypedGroup<FlxText>();
		add(icons);
		add(scoreView);

		for (i in 1...3)
		{
			scoreView.add(OHUtil.makeText(INIT_X, INIT_Y + ((i - 1) * 250), 0, (i > 1) ? 'HARD:' : 'NORMAL:', 40));
			var _accu = OHUtil.makeText(INIT_X, INIT_Y + 55 + ((i - 1) * 250), 0, accuLabel.toUpperCase() + ":", 40);
			var curAccu = OHUtil.makeText(_accu.x + _accu.width, _accu.y, 0, "-%", 40);
			var _score = OHUtil.makeText(INIT_X, _accu.y + 50, 0, comboLabel.toUpperCase() + ":", 40);
			var curScore = OHUtil.makeText(_score.x + _score.width, _score.y, 0, "0", 40);
			var _miss = OHUtil.makeText(INIT_X, _score.y + 50, 0, missesLabel.toUpperCase() + ":", 40);
			var curMiss = OHUtil.makeText(_miss.x + _miss.width, _miss.y, 0, "0", 40);
			for (spr in [_accu, curAccu, _score, curScore, _miss, curMiss])
				scoreView.add(spr);
		}

		songNames = new FlxTypedGroup<FlxText>();
		add(songNames);
		for (s in 0...songs.length)
		{
			var iconName = (songs[s] != null && songs[s].icon != null) ? songs[s].icon : 'face';
			var icon = new HealthIcon(iconName);
			icon.updateHitbox();
			icon.ID = s;
			icon.alpha = 0;
			icon.setPosition(INIT_X + 70, INIT_Y - icon.height - 15);
			icons.add(icon);

			var display = (songs[s] != null && songs[s].displayName != null) ? songs[s].displayName : '???';
			var text = OHUtil.makeText(INIT_X - 350, INIT_Y - 50 + (s * 50), 0, display, 40);
			if (text.text.toLowerCase() == 'marriage or disparage')
				text.text = 'MoD';
			text.updateHitbox();
			text.scrollFactor.set();
			songNames.add(text);
		}
		arrow = OHUtil.makeText(INIT_X - 400, INIT_Y - 50, 0, '>', 40);
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		songNames.add(arrow);

		if (songs.length > 0) changeItem();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) { close(); return; }

		if (songs.length > 0 && songNames != null && songNames.members.length > 0
			&& curSelected >= 0 && curSelected < songNames.members.length
			&& songNames.members[curSelected] != null)
		{
			arrow.y = songNames.members[curSelected].y;
		}

		if (controls.UI_UP_P) changeItem(-1);
		if (controls.UI_DOWN_P) changeItem(1);

		super.update(elapsed);
	}

	function changeIcon()
	{
		if (icons == null) return;
		icons.forEach(function(spr:HealthIcon)
		{
			spr.alpha = (spr.ID == curSelected) ? 1 : 0;
		});
	}

	function changeItem(huh:Int = 0)
	{
		if (songs.length == 0) return;
		curSelected = FlxMath.wrap(curSelected + huh, 0, songs.length - 1);
		changeIcon();
		updateInfo();
		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function updateInfo()
	{
		if (songs.length == 0 || curSelected < 0 || curSelected >= songs.length) return;
		var song = songs[curSelected];
		if (song == null) return;

		var diffs = (song.difficulties != null) ? song.difficulties : ['normal'];

		for (i in 7...14)
		{
			if (i < scoreView.members.length)
				scoreView.members[i].alpha = (diffs.length < 2) ? 0 : 1;
		}

		var data = OHUtil.getSongStats(song.name, diffs[0], song.weekName);
		var data2 = (diffs.length > 1) ? OHUtil.getSongStats(song.name, diffs[1], song.weekName) : OHUtil.emptyStats();
		if (data == null) data = OHUtil.emptyStats();
		if (data2 == null) data2 = OHUtil.emptyStats();

		if (scoreView.members.length > 13)
		{
			scoreView.members[2].text = Math.round(data.accuracy * 100) + "%";
			scoreView.members[4].text = Std.string(data.score);
			scoreView.members[6].text = Std.string(data.misses);
			scoreView.members[9].text = Math.round(data2.accuracy * 100) + "%";
			scoreView.members[11].text = Std.string(data2.score);
			scoreView.members[13].text = Std.string(data2.misses);
		}
	}
}
