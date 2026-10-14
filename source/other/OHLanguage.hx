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

class OHLanguage extends MusicBeatState
{
	var vcr:FlxRuntimeShader;
	var looptime:Float = 0;

	var texts:FlxTypedGroup<FlxText>;
	var rArrow:FlxText;
	var lArrow:FlxText;
	var flag:FlxSprite;

	var curSelected:Int = 0;
	var availableLanguages:Array<String> = ["english", "español"];
	var selectedSomethin:Bool = false;
	var fTime:Bool = false;

	public function new(fromTitle:Bool = false)
	{
		super();
		if (fromTitle) fTime = OHGlobal.firstTime;
	}

	override function create()
	{
		if (!fTime) vcr = OHUtil.setupVCR();

		flag = new FlxSprite(0, 0);
		try
		{
			flag.frames = Paths.getSparrowAtlas('menus/options/lang/lenguage');
			if (flag.frames != null)
			{
				flag.animation.addByPrefix('usa', 'lenguage usa', 24, true);
				flag.animation.addByPrefix('peru', 'lenguage peru', 24, true);
				flag.animation.play('usa');
			}
		}
		catch (e:Dynamic)
		{
			flag.makeGraphic(200, 150, 0xFF4444AA);
		}
		flag.antialiasing = ClientPrefs.data.antialiasing;
		flag.updateHitbox();
		flag.screenCenter();
		flag.y -= 50;
		flag.scrollFactor.set();
		add(flag);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		var c:Int = 0;
		for (i in availableLanguages)
		{
			var text = OHUtil.makeText(0, 500, 0, i.toUpperCase(), 90);
			text.ID = c;
			text.updateHitbox();
			text.scrollFactor.set();
			text.screenCenter(X);
			texts.add(text);
			c++;
		}

		lArrow = OHUtil.makeText(flag.x - 100, 500, 0, '<', 90);
		lArrow.scrollFactor.set();
		lArrow.updateHitbox();
		add(lArrow);

		rArrow = OHUtil.makeText(flag.x + flag.width + 50, 500, 0, '>', 90);
		rArrow.scrollFactor.set();
		rArrow.updateHitbox();
		add(rArrow);

		// Start on current language
		if (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr')
			curSelected = 1;

		changeItem();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!fTime && vcr != null)
		{
			looptime += elapsed;
			OHUtil.tickVCR(vcr, looptime);
		}

		if (!selectedSomethin)
		{
			if (controls.ACCEPT) selectItem();
			if (controls.UI_LEFT_P) changeItem(-1);
			if (controls.UI_RIGHT_P) changeItem(1);
			if (controls.BACK && !fTime)
				OHUtil.switchState(new OHOptions());
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + huh, 0, availableLanguages.length - 1);

		if (flag != null && flag.animation != null)
		{
			switch (availableLanguages[curSelected])
			{
				case 'english':
					if (flag.animation.getByName('usa') != null) flag.animation.play('usa');
				case 'español':
					if (flag.animation.getByName('peru') != null) flag.animation.play('peru');
			}
		}

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

		switch (availableLanguages[curSelected])
		{
			case 'english':
				OHGlobal.setLanguage('en-us');
			case 'español':
				OHGlobal.setLanguage('es-pr');
		}

		trace("Current Language -> EN: " + FlxG.save.data.enLang + " | ES: " + FlxG.save.data.esLang);

		try { FlxG.sound.play(Paths.sound('confirmMenu'), 1); } catch (_:Dynamic) {}
		FlxFlicker.flicker(texts.members[curSelected], 1, 0.08, false, false);

		new FlxTimer().start(1, function(_)
		{
			if (fTime)
			{
				OHGlobal.firstTime = false;
				OHUtil.switchState(new BetaWarningState());
			}
			else
				OHUtil.switchState(new OHOptions());
		});
	}
}
