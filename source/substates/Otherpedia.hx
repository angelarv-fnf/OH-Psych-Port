package substates;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import haxe.ds.StringMap;

typedef OtherpediaEntry =
{
	var eats:String;
	var loves:String;
	var hates:String;
	var origin:String;
	var desc:String;
	var file:String; // portrait
}

/**
 * Character encyclopedia, opened from OHExtras.
 * Data: data/config/language/otherpedia/<en|es>/info.xml
 */
class Otherpedia extends MusicBeatSubstate
{
	var data:Xml;
	var info:StringMap<OtherpediaEntry> = new StringMap<OtherpediaEntry>();
	var charOrder:Array<String> = []; // keeps the xml order (StringMap.keys() has no guaranteed order)
	var infoSize:Int = 0;

	var charNames:FlxTypedGroup<FlxText>;
	var arrow:FlxText;

	var currentCharacter:FlxText;
	var eatsText:FlxText;
	var lovesText:FlxText;
	var hatesText:FlxText;
	var originText:FlxText;
	var attText:Dynamic;
	var portraits:FlxTypedGroup<FlxSprite>;
	var portraitFrame:FlxSprite;
	var desc:FlxText;

	var INIT_X:Int = 700;
	var INIT_Y:Int = 100;

	var curSelected:Int = 0;

	// 272 x 489
	override function create()
	{
		super.create();

		attText = OHGlobal.lang.languageTree.menus.Extras.otherpedia;

		var suffix:String = (OHGlobal.lang.currentLanguage == 'es-pr') ? 'es' : 'en';
		var xmlText:String = Paths.getTextFromFile('data/config/language/otherpedia/' + suffix + '/info.xml');
		if (xmlText != null && xmlText.length > 0)
			data = Xml.parse(xmlText).firstElement();

		if (data == null)
		{
			trace("Parsing Error");
			close();
			return;
		}

		parseData();

		currentCharacter = OHUtil.makeText(INIT_X + 15, INIT_Y - 65, 0, 'Hi :3', 60, CENTER);
		add(currentCharacter);

		charNames = new FlxTypedGroup<FlxText>();
		add(charNames);
		var c:Int = 0;
		for (char in charOrder)
		{
			var text:FlxText = OHUtil.makeText(INIT_X - 300, INIT_Y - 50 + (c * 50), 0, char, 28);
			text.updateHitbox();
			text.scrollFactor.set();
			charNames.add(text);
			c++;
		}
		arrow = OHUtil.makeText(INIT_X - 330, INIT_Y - 50, 0, '>', 28);
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		charNames.add(arrow);

		portraitFrame = new FlxSprite(INIT_X + 20, INIT_Y + 30).makeGraphic(Std.int(272 * 0.6), Std.int(489 * 0.6), FlxColor.fromString('#070707'));
		portraitFrame.updateHitbox();
		add(portraitFrame);

		portraits = new FlxTypedGroup<FlxSprite>();
		add(portraits);
		c = 0;
		for (f in charOrder)
		{
			var curInfo:OtherpediaEntry = info.get(f);
			var portrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/extras/otherpedia/' + curInfo.file));
			portrait.antialiasing = ClientPrefs.data.antialiasing;
			portrait.ID = c;
			portrait.setGraphicSize(portraitFrame.width, portraitFrame.height);
			portrait.updateHitbox();
			portrait.setPosition(portraitFrame.x, portraitFrame.y);
			portrait.alpha = 0;
			portraits.add(portrait);
			c++;
		}

		var eatsLabel:String = attText.eats;
		var lovesLabel:String = attText.loves;
		var hatesLabel:String = attText.hates;
		var originLabel:String = attText.origin;

		var _eats:FlxText = OHUtil.makeText((portraitFrame.x + portraitFrame.width) + 30, portraitFrame.y + 30, 0, eatsLabel + ': ', 26);
		eatsText = OHUtil.makeText(_eats.x + _eats.width, _eats.y, 300, '', 26);
		var _loves:FlxText = OHUtil.makeText(_eats.x, _eats.y + 65, 0, lovesLabel + ': ', 26);
		lovesText = OHUtil.makeText(_loves.x + _loves.width, _loves.y, 300, '', 26);
		var _hates:FlxText = OHUtil.makeText(_eats.x, _loves.y + 65, 0, hatesLabel + ': ', 26);
		hatesText = OHUtil.makeText(_hates.x + _hates.width, _hates.y, 300, '', 26);
		var _origin:FlxText = OHUtil.makeText(_eats.x, _hates.y + 65, 0, originLabel + ': ', 26);
		originText = OHUtil.makeText(_origin.x + _origin.width, _origin.y, 300, '', 26);

		for (txt in [_eats, eatsText, _loves, lovesText, _hates, hatesText, _origin, originText])
		{
			add(txt);
		}

		desc = OHUtil.makeText(INIT_X, INIT_Y * 4.5, 480, 'Hello there! :3', 20);
		add(desc);

		changeItem();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			close();
			return;
		}

		if (infoSize > 0)
		{
			arrow.y = charNames.members[curSelected].y;

			if (controls.UI_UP_P)
				changeItem(-1);
			if (controls.UI_DOWN_P)
				changeItem(1);
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, infoSize - 1);

		changePortrait();
		updateInfo();

		FlxG.sound.play(Paths.sound('menu/scroll'), 0.7);
	}

	function updateInfo()
	{
		var charToFetch:String = charOrder[curSelected];
		var newInfo:OtherpediaEntry = info.get(charToFetch);

		eatsText.text = newInfo.eats;
		lovesText.text = newInfo.loves;
		hatesText.text = newInfo.hates;
		originText.text = newInfo.origin;

		// flatten the xml text block into a single paragraph
		var curText:String = StringTools.trim(newInfo.desc.split('\n').join(' ').split('\r').join(' ').split('          ').join(''));
		desc.text = curText;
		currentCharacter.text = charToFetch;
		currentCharacter.updateHitbox();
	}

	function changePortrait()
	{
		portraits.forEach(function(spr:FlxSprite)
		{
			spr.alpha = (spr.ID == curSelected) ? 1 : 0;
		});
	}

	function parseData()
	{
		for (entry in data.elements())
		{
			var curData:OtherpediaEntry = {
				eats: '',
				loves: '',
				hates: '',
				origin: '',
				desc: '',
				file: ('ext_' + entry.get('file'))
			};
			for (at in entry.iterator())
			{
				if (at.nodeType == Xml.PCData)
				{
					// PCData <- Description
					curData.desc = at.nodeValue;
				}
				else if (at.nodeType == Xml.Element)
				{
					// Element <- Attribute
					Reflect.setField(curData, at.get('type').toLowerCase(), at.get('value'));
				}
			}

			var name:String = entry.get('name');
			info.set(name, curData);
			charOrder.push(name);
			infoSize++;
		}
	}
}
