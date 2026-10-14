package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;

class OHOptions extends MusicBeatState
{
	var texts:FlxTypedGroup<FlxText>;
	var arrow:FlxText;
	var bg:FlxSprite;

	var INIT_X:Int = 130;
	var INIT_Y:Int = 100;

	var curSelected:Int = 0;
	var vcr:FlxRuntimeShader;
	var selectedSomethin:Bool = false;

	var optionShit:Array<String> = ["language", "Ex. Mode", "other options"];
	var looptime:Float = 0;

	override function create()
	{
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Options != null
				&& OHGlobal.lang.languageTree.menus.Options.optionShit != null)
			{
				optionShit = OHGlobal.lang.languageTree.menus.Options.optionShit;
			}
		}
		catch (e:Dynamic)
		{
			trace("OHOptions: language fallback -> " + e);
		}

		vcr = OHUtil.setupVCR();

		bg = OHUtil.makeMenuBG();
		if (bg == null)
			bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF0a0a0c);
		add(bg);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		var c:Int = 0;
		for (i in optionShit)
		{
			var text = OHUtil.makeText(INIT_X, INIT_Y + (c * 100), 0, i.toUpperCase(), 90);
			text.ID = c;
			text.updateHitbox();
			text.scrollFactor.set();
			texts.add(text);
			c++;
		}
		arrow = OHUtil.makeText(INIT_X - 60, INIT_Y, 0, '>', 90);
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		texts.add(arrow);

		changeItem();
		super.create();
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

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
			if (controls.BACK) OHUtil.switchState(new MainMenuState());
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
		if (texts == null || texts.members.length == 0) return;
		if (curSelected < 0 || curSelected >= texts.members.length) return;

		selectedSomethin = true;
		try { FlxG.sound.play(Paths.sound('confirmMenu'), 1); } catch (_:Dynamic) {}

		FlxFlicker.flicker(texts.members[curSelected], 1, 0.08, false, false);

		texts.forEach(function(t:FlxText)
		{
			if (t.ID != curSelected) t.alpha = 0;
		});

		new FlxTimer().start(1, function(_)
		{
			switch (curSelected)
			{
				case 0: OHUtil.switchState(new OHLanguage());
				case 1: OHUtil.switchState(new OHExMode());
				case 2: LoadingState.loadAndSwitchState(new options.OptionsState());
			}
		});
	}
}
