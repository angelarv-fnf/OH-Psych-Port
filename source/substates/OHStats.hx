package substates;

import backend.OHGlobal;
import backend.OHUtil;
import backend.OHUtil.OHSongEntry;
import backend.OHUtil.OHSongStats;

import objects.HealthIcon;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

/**
 * Statistics screen, opened from OHExtras.
 *
 * scoreView layout (kept from the script, indices matter in updateInfo):
 *   0 label | 1 accu label | 2 accu | 3 combo label | 4 score | 5 misses label | 6 misses   (first difficulty block)
 *   7 label | 8 accu label | 9 accu | 10 combo label | 11 score | 12 misses label | 13 misses  (second difficulty block)
 */
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

	var statsInfo:Dynamic;

	override function create()
	{
		super.create();

		statsInfo = OHGlobal.lang.languageTree.menus.Extras.stats;
		var accuLabel:String = statsInfo.accu;
		var comboLabel:String = statsInfo.combo;
		var missesLabel:String = statsInfo.misses;

		// Data thing
		songs = OHUtil.loadSongList();

		icons = new FlxTypedGroup<HealthIcon>();
		scoreView = new FlxTypedGroup<FlxText>();
		add(icons);
		add(scoreView);

		for (i in 1...3)
		{
			scoreView.add(OHUtil.makeText(INIT_X, INIT_Y + ((i - 1) * 250), 0, (i > 1) ? 'HARD:' : 'NORMAL:', 40));
			var _accuText:FlxText = OHUtil.makeText(INIT_X, INIT_Y + 55 + ((i - 1) * 250), 0, accuLabel.toUpperCase() + ":", 40);
			var curAccuText:FlxText = OHUtil.makeText(_accuText.x + _accuText.width, _accuText.y, 0, "-%", 40);

			var _scoreText:FlxText = OHUtil.makeText(INIT_X, _accuText.y + 50, 0, comboLabel.toUpperCase() + ":", 40);
			var curScoreText:FlxText = OHUtil.makeText(_scoreText.x + _scoreText.width, _scoreText.y, 0, "0", 40);

			var _missesText:FlxText = OHUtil.makeText(INIT_X, _scoreText.y + 50, 0, missesLabel.toUpperCase() + ":", 40);
			var curMissesText:FlxText = OHUtil.makeText(_missesText.x + _missesText.width, _missesText.y, 0, "0", 40);

			for (spr in [_accuText, curAccuText, _scoreText, curScoreText, _missesText, curMissesText])
			{
				scoreView.add(spr);
			}
		}

		songNames = new FlxTypedGroup<FlxText>();
		add(songNames);
		for (s in 0...songs.length)
		{
			var icon:HealthIcon = new HealthIcon(songs[s].icon);
			icon.updateHitbox();
			icon.ID = s;
			icon.alpha = 0;
			icon.setPosition(INIT_X + 70, INIT_Y - icon.height - 15);
			icons.add(icon);

			var text:FlxText = OHUtil.makeText(INIT_X - 350, INIT_Y - 50 + (s * 50), 0, songs[s].displayName, 40);
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

		changeItem();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			close();
			return;
		}

		arrow.y = songNames.members[curSelected].y;

		if (controls.UI_UP_P)
			changeItem(-1);
		if (controls.UI_DOWN_P)
			changeItem(1);

		super.update(elapsed);
	}

	function changeIcon()
	{
		icons.forEach(function(spr:HealthIcon)
		{
			spr.alpha = (spr.ID == curSelected) ? 1 : 0;
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + huh, 0, songs.length - 1);

		changeIcon();
		updateInfo();

		FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
	}

	function updateInfo()
	{
		var song:OHSongEntry = songs[curSelected];
		var _diffs:Array<String> = song.difficulties;

		// kept from the script: the second block is hidden when the first difficulty is NORMAL
		for (i in 7...14)
		{
			scoreView.members[i].alpha = (_diffs[0].toUpperCase() == 'NORMAL') ? 0 : 1;
		}

		var data:OHSongStats = OHUtil.getSongStats(song.name, _diffs[0], song.weekName);
		var data2:OHSongStats = (_diffs.length > 1) ? OHUtil.getSongStats(song.name, _diffs[1], song.weekName) : OHUtil.emptyStats();

		scoreView.members[2].text = Math.round(data.accuracy * 100) + "%";
		scoreView.members[4].text = Std.string(data.score);
		scoreView.members[6].text = Std.string(data.misses);

		scoreView.members[9].text = Math.round(data2.accuracy * 100) + "%";
		scoreView.members[11].text = Std.string(data2.score);
		scoreView.members[13].text = Std.string(data2.misses);
	}
}
