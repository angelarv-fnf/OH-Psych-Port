package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxRuntimeShader;

/**
 * Other Halloween main menu.
 * Story / Shop locked with scare messages. Extras unlock after beating RED.
 */
class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';

	static inline var EXTRAS_INDEX:Int = 5;

	var wipText:Array<String> = [
		"This is on Development\nyou fool!",
		"The shop is closed\nstranger!",
		"You must complete\nthe following\nto unlock this:|Complete the song RED"
	];
	var optionShit:Array<String> = ["story mode", "freeplay", "options", "credits", "shop", "extras"];

	var scareText:FlxText;
	var otherText:FlxText;
	var alphaBG:FlxSprite;
	var texts:FlxTypedGroup<FlxText>;
	var arrow:FlxText;
	var bg:FlxSprite;

	var INIT_X:Int = 130;
	var INIT_Y:Int = 100;

	var vcr:FlxRuntimeShader;
	var looptime:Float = 0;

	var curSelected:Int = 0;
	var canSelect:Bool = true;
	var selectedSomethin:Bool = false;

	var unlockedExtras:Bool = false;
	var justUnlocked:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		FlxG.mouse.visible = false;

		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.MainMenu != null)
			{
				var m = OHGlobal.lang.languageTree.menus.MainMenu;
				if (m.wipSub != null) wipText = m.wipSub;
				if (m.optionShit != null) optionShit = m.optionShit;
			}
		}
		catch (e:Dynamic)
		{
			trace("MainMenuState: language fallback -> " + e);
		}

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			try { FlxG.sound.playMusic(Paths.music('menus/main_menu'), 1); } catch (_:Dynamic) {}
		}

		vcr = OHUtil.setupVCR();

		bg = OHUtil.makeMenuBG();
		if (bg == null)
			bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		texts = new FlxTypedGroup<FlxText>();
		add(texts);
		var c:Int = 0;
		for (i in optionShit)
		{
			var text = OHUtil.makeText(INIT_X, INIT_Y + (c * 90), 0, i.toUpperCase(), 90);
			if (c <= 0 || c >= optionShit.length - 2)
				text.color = FlxColor.RED;
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

		alphaBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		alphaBG.scrollFactor.set();
		alphaBG.alpha = 0;
		add(alphaBG);

		scareText = OHUtil.makeText(0, 0, 0, "", 90);
		scareText.scrollFactor.set();
		scareText.color = FlxColor.RED;
		scareText.alpha = 0;
		scareText.screenCenter();
		add(scareText);

		otherText = OHUtil.makeText(0, 0, 0, "", 65);
		otherText.scrollFactor.set();
		otherText.alpha = 0;
		otherText.y = 550;
		add(otherText);

		checkUnlocked();

		if (texts.members.length > EXTRAS_INDEX)
		{
			var extras = texts.members[EXTRAS_INDEX];
			if (justUnlocked)
			{
				new FlxTimer().start(0.5, function(_)
				{
					FlxTween.tween(extras, {angle: 8}, 0.2, {ease: FlxEase.circOut, onComplete: function(_)
					{
						FlxTween.tween(extras, {angle: -8}, 0.2, {ease: FlxEase.circOut, onComplete: function(_)
						{
							extras.color = FlxColor.WHITE;
							FlxTween.tween(extras, {angle: 0}, 0.2, {ease: FlxEase.circOut});
						}});
					}});
				});
			}
			else if (unlockedExtras)
				extras.color = FlxColor.WHITE;
		}

		changeItem();
		super.create();
	}

	function checkUnlocked()
	{
		if (OHGlobal.debugMode)
		{
			unlockedExtras = true;
			justUnlocked = true;
			return;
		}

		var dataCheck = OHUtil.getSongStats('red', 'normal');
		if (dataCheck != null && dataCheck.score > 0)
			unlockedExtras = true;

		if (FlxG.save.data.completedRed == true)
		{
			justUnlocked = true;
			FlxG.save.data.completedRed = false;
			FlxG.save.flush();
		}
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		if (controls.ACCEPT) selectItem();
		if (controls.UI_UP_P) changeItem(-1);
		if (controls.UI_DOWN_P) changeItem(1);

		if (FlxG.keys.justPressed.SEVEN && !OHGlobal.debugMode)
		{
			OHUtil.switchState(new NoCheatingState());
			return;
		}

		if (!selectedSomethin && texts != null && texts.members.length > 0
			&& curSelected >= 0 && curSelected < texts.members.length
			&& texts.members[curSelected] != null)
		{
			arrow.y = texts.members[curSelected].y;
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (!canSelect || optionShit == null || optionShit.length == 0) return;
		curSelected = FlxMath.wrap(curSelected + huh, 0, optionShit.length - 1);
		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function selectItem()
	{
		if (!canSelect || optionShit == null || optionShit.length == 0) return;
		if (texts == null || texts.members.length == 0) return;
		if (curSelected < 0 || curSelected >= texts.members.length) return;

		selectedSomethin = true;
		canSelect = false;

		FlxFlicker.flicker(texts.members[curSelected], 1, 0.08, true, true);

		texts.forEach(function(t:FlxText)
		{
			if (t.ID != curSelected) t.alpha = 0;
		});

		new FlxTimer().start(1, function(_)
		{
			switch (curSelected)
			{
				case 0:
					notYet(0);
				case 1:
					scareTransition(function() return new FreeplayState());
				case 2:
					OHUtil.switchState(new OHOptions());
				case 3:
					scareTransition(function() return new CreditsState());
				case 4:
					notYet(1);
				case 5:
					if (!unlockedExtras) notYet(2);
					else scareTransition(function() return new OHExtras());
			}
		});
	}

	function notYet(type:Int)
	{
		var sound:String = '';
		var _text:Array<String> = (type == 2 && wipText.length > 2)
			? wipText[type].split("|")
			: [wipText[Std.int(Math.min(type, wipText.length - 1))].toUpperCase()];
		var suffix:String = (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr') ? "-es" : "";

		FlxG.camera.flash(FlxColor.WHITE, 0.5);
		try { FlxG.sound.play(Paths.sound('menu/Terror 1'), 1); } catch (_:Dynamic) {}
		alphaBG.alpha = 0.8;
		scareText.alpha = 1;
		scareText.text = _text[0];
		scareText.screenCenter();

		switch (type)
		{
			case 0: sound = 'menu/story_closed' + suffix;
			case 1: sound = 'menu/shop_closed' + suffix;
			case 2:
				sound = 'menu/extra_closed' + suffix;
				if (_text.length > 1)
				{
					otherText.alpha = 1;
					otherText.text = _text[1];
					otherText.screenCenter(X);
				}
		}

		new FlxTimer().start(0.5, function(_)
		{
			try { FlxG.sound.play(Paths.sound(sound), 1); } catch (_:Dynamic) {}
		});

		new FlxTimer().start(1.5, function(_)
		{
			FlxTween.tween(alphaBG, {alpha: 0}, 4);
			FlxTween.tween(scareText, {alpha: 0}, 4, {onComplete: function(_)
			{
				selectedSomethin = false;
				canSelect = true;
			}});
			if (type == 2) FlxTween.tween(otherText, {alpha: 0}, 4);
		});

		if (texts != null)
		{
			texts.forEach(function(t:FlxText) t.alpha = 1);
		}
	}

	function scareTransition(next:Void->FlxState)
	{
		var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		FlxG.camera.flash(FlxColor.WHITE, 0.5);
		try { FlxG.sound.play(Paths.sound('menu/Terror 2'), 1); } catch (_:Dynamic) {}

		new FlxTimer().start(5, function(_)
		{
			OHUtil.switchState(next());
		});
	}
}
