package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class OHExtras extends MusicBeatState
{
	var texts:FlxTypedGroup<FlxText>;
	var title:FlxText;
	var arrow:FlxText;
	var nope:FlxText;

	var INIT_X:Int = 50;
	var INIT_Y:Int = 150;

	var curSelected:Int = 0;
	var selectedSomethin:Bool = false;

	var optionShit:Array<String> = ["achievements", "statistics", "gallery", "otherpedia"];

	override function create()
	{
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Extras != null
				&& OHGlobal.lang.languageTree.menus.Extras.optionShit != null)
			{
				optionShit = OHGlobal.lang.languageTree.menus.Extras.optionShit;
			}
		}
		catch (e:Dynamic)
		{
			trace("OHExtras: language fallback used -> " + e);
		}

		title = OHUtil.makeText(50, 40, 0, 'EXTRAS', 80);
		add(title);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		var c:Int = 0;
		for (i in optionShit)
		{
			var text:FlxText = OHUtil.makeText(INIT_X, INIT_Y + (c * 55), 0, i.toUpperCase(), 40);
			// Achievements stay red (not implemented)
			if (c == 0)
				text.color = FlxColor.RED;
			text.ID = c;
			text.updateHitbox();
			text.scrollFactor.set();
			texts.add(text);
			c++;
		}
		arrow = OHUtil.makeText(INIT_X - 30, INIT_Y, 0, '>', 40);
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		texts.add(arrow);

		nope = OHUtil.makeText(0, 0, 0, 'NOT AVAILABLE YET', 32);
		nope.color = FlxColor.RED;
		nope.y = FlxG.height - nope.height - 100;
		nope.screenCenter(X);
		nope.alpha = 0;
		add(nope);

		changeItem();

		try
		{
			FlxG.sound.playMusic(Paths.music('menus/shop_theme'), 0.3, false);
			if (FlxG.sound.music != null)
				FlxG.sound.music.persist = false;
		}
		catch (e:Dynamic) {}

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (texts != null && texts.members.length > 0
				&& curSelected >= 0 && curSelected < texts.members.length
				&& texts.members[curSelected] != null)
			{
				arrow.y = texts.members[curSelected].y;
			}

			if (controls.ACCEPT) selectItem();
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);
			if (controls.BACK)
				OHUtil.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (optionShit == null || optionShit.length == 0) return;
		curSelected = FlxMath.wrap(curSelected + huh, 0, optionShit.length - 1);
		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function selectItem()
	{
		try { FlxG.sound.play(Paths.sound('confirmMenu'), 1); } catch (_:Dynamic) {}

		switch (curSelected)
		{
			case 0: // achievements – still not implemented
				notYet();
			case 1: // statistics
				persistentUpdate = false;
				openSubState(new OHStats());
			case 2: // gallery
				persistentUpdate = false;
				openSubState(new OHGallery());
			case 3: // otherpedia
				persistentUpdate = false;
				openSubState(new Otherpedia());
		}
	}

	function notYet()
	{
		if (nope == null) return;
		FlxTween.cancelTweensOf(nope);
		nope.alpha = 0;
		FlxTween.tween(nope, {alpha: 1}, 0.5);
		FlxTween.tween(nope, {alpha: 0}, 0.5, {startDelay: 1});
	}

	override function closeSubState()
	{
		selectedSomethin = false;
		persistentUpdate = true;
		super.closeSubState();
	}
}
