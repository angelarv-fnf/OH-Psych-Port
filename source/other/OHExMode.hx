package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;

class OHExMode extends MusicBeatState
{
	var msg:Array<String> = [
		"Warning",
		"This option allows you to see explicit content (like *GORE*, *VIOLENCE*, etc) that are not suitable for everyone.\n",
		"However, this doesn't disable scary things like Jumpscares."
	];
	var options:Array<String> = ["ON", "OFF"];
	var curSelected:Int = 0;

	var vcr:FlxRuntimeShader;
	var looptime:Float = 0;

	var title:FlxText;
	var goreWarning:FlxText;
	var rArrow:FlxText;
	var lArrow:FlxText;
	var texts:FlxTypedGroup<FlxText>;

	var selectedSomethin:Bool = false;

	override function create()
	{
		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Options != null
				&& OHGlobal.lang.languageTree.menus.Options.exMode != null
				&& OHGlobal.lang.languageTree.menus.Options.exMode.msg != null)
			{
				msg = OHGlobal.lang.languageTree.menus.Options.exMode.msg;
			}
		}
		catch (e:Dynamic)
		{
			trace("OHExMode: language fallback -> " + e);
		}

		vcr = OHUtil.setupVCR();

		title = OHUtil.makeText(0, 150, 0, (msg.length > 0 ? msg[0] : "EXPLICIT MODE").toUpperCase(), 90, CENTER);
		title.updateHitbox();
		title.scrollFactor.set();
		title.color = FlxColor.RED;
		title.screenCenter(X);
		add(title);

		var warnStr:String = (msg.length > 1 ? msg[1] : "") + (msg.length > 2 ? msg[2] : "");
		goreWarning = OHUtil.makeText(0, 250, FlxG.width - 48, "", 48, CENTER);
		OHUtil.applyMarkup(goreWarning, warnStr);
		goreWarning.screenCenter(X);
		add(goreWarning);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		var c:Int = 0;
		for (i in options)
		{
			var text = OHUtil.makeText(0, 550, 0, i.toUpperCase(), 90);
			text.ID = c;
			text.updateHitbox();
			text.scrollFactor.set();
			text.screenCenter(X);
			texts.add(text);
			c++;
		}

		lArrow = OHUtil.makeText(title.x - 100, 550, 0, '<', 90);
		lArrow.scrollFactor.set();
		lArrow.updateHitbox();
		add(lArrow);

		rArrow = OHUtil.makeText(title.x + title.width + 50, 550, 0, '>', 90);
		rArrow.scrollFactor.set();
		rArrow.updateHitbox();
		add(rArrow);

		// Start on current setting
		curSelected = OHGlobal.explicitMode ? 0 : 1;
		changeItem();

		super.create();
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		if (!selectedSomethin)
		{
			if (controls.ACCEPT) selectItem();
			if (controls.UI_LEFT_P) changeItem(-1);
			if (controls.UI_RIGHT_P) changeItem(1);
			if (controls.BACK) OHUtil.switchState(new OHOptions());
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + huh, 0, options.length - 1);

		if (texts != null)
		{
			texts.forEach(function(t:FlxText)
			{
				t.alpha = (t.ID == curSelected) ? 1 : 0;
			});
		}

		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function selectItem()
	{
		if (texts == null || texts.members.length == 0) return;
		if (curSelected < 0 || curSelected >= texts.members.length) return;

		selectedSomethin = true;

		switch (options[curSelected])
		{
			case 'ON':
				OHGlobal.setExplicit(true);
			case 'OFF':
				OHGlobal.setExplicit(false);
		}

		trace("Explicit Mode -> " + FlxG.save.data.expMode);

		try { FlxG.sound.play(Paths.sound('confirmMenu'), 1); } catch (_:Dynamic) {}
		FlxFlicker.flicker(texts.members[curSelected], 1, 0.08, false, false);

		new FlxTimer().start(1, function(_)
		{
			OHUtil.switchState(new OHOptions());
		});
	}
}
