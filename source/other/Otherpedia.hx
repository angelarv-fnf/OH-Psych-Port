package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxSprite;
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
	var file:String;
}

class Otherpedia extends MusicBeatSubstate
{
	var data:Xml;
	var info:StringMap<OtherpediaEntry> = new StringMap<OtherpediaEntry>();
	var charOrder:Array<String> = [];
	var infoSize:Int = 0;

	var charNames:FlxTypedGroup<FlxText>;
	var arrow:FlxText;
	var currentCharacter:FlxText;
	var eatsText:FlxText;
	var lovesText:FlxText;
	var hatesText:FlxText;
	var originText:FlxText;
	var attText:Dynamic = null;
	var portraits:FlxTypedGroup<FlxSprite>;
	var portraitFrame:FlxSprite;
	var desc:FlxText;

	var INIT_X:Int = 700;
	var INIT_Y:Int = 100;
	var curSelected:Int = 0;

	override function create()
	{
		super.create();

		try
		{
			if (OHGlobal.lang != null && OHGlobal.lang.languageTree != null
				&& OHGlobal.lang.languageTree.menus != null
				&& OHGlobal.lang.languageTree.menus.Extras != null)
			{
				attText = OHGlobal.lang.languageTree.menus.Extras.otherpedia;
			}
		}
		catch (e:Dynamic) {}

		if (attText == null)
			attText = {eats: "Eats", loves: "Loves", hates: "Hates", origin: "Origin"};

		var suffix:String = (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr') ? 'es' : 'en';
		var xmlText:String = null;
		try
		{
			xmlText = Paths.getTextFromFile('data/config/language/otherpedia/' + suffix + '/info.xml');
		}
		catch (e:Dynamic)
		{
			trace("Otherpedia: xml load failed -> " + e);
		}

		if (xmlText != null && xmlText.length > 0)
		{
			try { data = Xml.parse(xmlText).firstElement(); }
			catch (e:Dynamic) { data = null; }
		}

		if (data == null)
		{
			trace("Otherpedia: no data – closing");
			close();
			return;
		}

		parseData();
		if (infoSize == 0) { close(); return; }

		currentCharacter = OHUtil.makeText(INIT_X + 15, INIT_Y - 65, 0, '', 60, CENTER);
		add(currentCharacter);

		charNames = new FlxTypedGroup<FlxText>();
		add(charNames);
		var c:Int = 0;
		for (char in charOrder)
		{
			var text = OHUtil.makeText(INIT_X - 300, INIT_Y - 50 + (c * 50), 0, char, 28);
			text.updateHitbox();
			text.scrollFactor.set();
			charNames.add(text);
			c++;
		}
		arrow = OHUtil.makeText(INIT_X - 330, INIT_Y - 50, 0, '>', 28);
		arrow.scrollFactor.set();
		arrow.updateHitbox();
		charNames.add(arrow);

		portraitFrame = new FlxSprite(INIT_X + 20, INIT_Y + 30)
			.makeGraphic(Std.int(272 * 0.6), Std.int(489 * 0.6), FlxColor.fromString('#070707'));
		portraitFrame.updateHitbox();
		add(portraitFrame);

		portraits = new FlxTypedGroup<FlxSprite>();
		add(portraits);
		c = 0;
		for (f in charOrder)
		{
			var curInfo = info.get(f);
			var portrait = new FlxSprite();
			if (curInfo != null && curInfo.file != null)
			{
				try { portrait.loadGraphic(Paths.image('menus/extras/otherpedia/' + curInfo.file)); }
				catch (e:Dynamic)
				{
					portrait.makeGraphic(Std.int(portraitFrame.width), Std.int(portraitFrame.height), 0xFF333333);
				}
			}
			else
			{
				portrait.makeGraphic(Std.int(portraitFrame.width), Std.int(portraitFrame.height), 0xFF333333);
			}
			portrait.antialiasing = ClientPrefs.data.antialiasing;
			portrait.ID = c;
			portrait.setGraphicSize(Std.int(portraitFrame.width), Std.int(portraitFrame.height));
			portrait.updateHitbox();
			portrait.setPosition(portraitFrame.x, portraitFrame.y);
			portrait.alpha = 0;
			portraits.add(portrait);
			c++;
		}

		var eatsLabel = (attText.eats != null) ? attText.eats : "Eats";
		var lovesLabel = (attText.loves != null) ? attText.loves : "Loves";
		var hatesLabel = (attText.hates != null) ? attText.hates : "Hates";
		var originLabel = (attText.origin != null) ? attText.origin : "Origin";

		var _eats = OHUtil.makeText((portraitFrame.x + portraitFrame.width) + 30, portraitFrame.y + 30, 0, eatsLabel + ': ', 26);
		eatsText = OHUtil.makeText(_eats.x + _eats.width, _eats.y, 300, '', 26);
		var _loves = OHUtil.makeText(_eats.x, _eats.y + 65, 0, lovesLabel + ': ', 26);
		lovesText = OHUtil.makeText(_loves.x + _loves.width, _loves.y, 300, '', 26);
		var _hates = OHUtil.makeText(_eats.x, _loves.y + 65, 0, hatesLabel + ': ', 26);
		hatesText = OHUtil.makeText(_hates.x + _hates.width, _hates.y, 300, '', 26);
		var _origin = OHUtil.makeText(_eats.x, _hates.y + 65, 0, originLabel + ': ', 26);
		originText = OHUtil.makeText(_origin.x + _origin.width, _origin.y, 300, '', 26);

		for (txt in [_eats, eatsText, _loves, lovesText, _hates, hatesText, _origin, originText])
			add(txt);

		desc = OHUtil.makeText(INIT_X, INIT_Y * 4.5, 480, '', 20);
		add(desc);

		changeItem();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) { close(); return; }

		if (infoSize > 0 && charNames != null && charNames.members.length > 0)
		{
			if (curSelected >= 0 && curSelected < charNames.members.length
				&& charNames.members[curSelected] != null)
			{
				arrow.y = charNames.members[curSelected].y;
			}
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		if (infoSize <= 0) return;
		curSelected = FlxMath.wrap(curSelected + change, 0, infoSize - 1);
		changePortrait();
		updateInfo();
		try { FlxG.sound.play(Paths.sound('scrollMenu'), 0.7); } catch (_:Dynamic) {}
	}

	function updateInfo()
	{
		if (charOrder.length == 0 || curSelected < 0 || curSelected >= charOrder.length) return;
		var charToFetch = charOrder[curSelected];
		var newInfo = info.get(charToFetch);
		if (newInfo == null) return;

		if (eatsText != null) eatsText.text = (newInfo.eats != null) ? newInfo.eats : '';
		if (lovesText != null) lovesText.text = (newInfo.loves != null) ? newInfo.loves : '';
		if (hatesText != null) hatesText.text = (newInfo.hates != null) ? newInfo.hates : '';
		if (originText != null) originText.text = (newInfo.origin != null) ? newInfo.origin : '';

		var rawDesc = (newInfo.desc != null) ? newInfo.desc : '';
		var curText = StringTools.trim(rawDesc.split('\n').join(' ').split('\r').join(' ').split('          ').join(''));
		if (desc != null) desc.text = curText;
		if (currentCharacter != null)
		{
			currentCharacter.text = charToFetch;
			currentCharacter.updateHitbox();
		}
	}

	function changePortrait()
	{
		if (portraits == null) return;
		portraits.forEach(function(spr:FlxSprite)
		{
			spr.alpha = (spr.ID == curSelected) ? 1 : 0;
		});
	}

	function parseData()
	{
		if (data == null) return;
		for (entry in data.elements())
		{
			var curData:OtherpediaEntry = {
				eats: '', loves: '', hates: '', origin: '', desc: '',
				file: ('ext_' + (entry.get('file') != null ? entry.get('file') : 'unknown'))
			};
			for (at in entry.iterator())
			{
				if (at.nodeType == Xml.PCData)
					curData.desc = at.nodeValue;
				else if (at.nodeType == Xml.Element)
				{
					var type = at.get('type');
					if (type != null)
						Reflect.setField(curData, type.toLowerCase(), at.get('value'));
				}
			}
			var name = entry.get('name');
			if (name == null) name = "Unknown";
			info.set(name, curData);
			charOrder.push(name);
			infoSize++;
		}
	}
}
