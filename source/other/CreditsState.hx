package other;

import backend.OHGlobal;
import backend.OHUtil;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxRuntimeShader;

typedef CreditEntry =
{
	var name:String;
	var desc:String;
	var icon:String;
	var url:String;
}

class CreditsState extends MusicBeatState
{
	var data:Xml;
	var INIT_Y:Int = 50;
	var curSelected:Int = 0;

	var arrow:FlxText;
	var title:FlxText;
	var descText:FlxText;
	var bg:FlxSprite;
	var tv:FlxSprite;
	var tvView:FlxSpriteGroup;
	var membersList:FlxTypedGroup<FlxText>;
	var tvIn:FlxCamera;
	var outView:FlxCamera;

	var vcr:FlxRuntimeShader;
	var looptime:Float = 0;
	var info:Array<CreditEntry> = [];

	override function create()
	{
		tvIn = new FlxCamera();
		tvIn.bgColor = 0;
		outView = new FlxCamera();
		outView.bgColor = 0;
		FlxG.cameras.add(tvIn, false);
		FlxG.cameras.add(outView, false);

		bg = new FlxSprite(0, 0);
		try { bg.loadGraphic(Paths.image('credits/frames/bg_credits')); }
		catch (e:Dynamic) { bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK); }
		bg.antialiasing = ClientPrefs.data.antialiasing;

		tv = new FlxSprite();
		try
		{
			tv.frames = Paths.getSparrowAtlas('credits/frames/tv');
			if (tv.frames != null)
				tv.animation.addByPrefix('idle', 'tv idle', 24, true);
		}
		catch (e:Dynamic)
		{
			tv.makeGraphic(400, 300, FlxColor.GRAY);
		}
		tv.antialiasing = ClientPrefs.data.antialiasing;
		tv.cameras = [outView];

		title = OHUtil.makeText(0, 10, 0, "CREDITS", 90);
		title.screenCenter(X);
		title.cameras = [outView];

		tvView = new FlxSpriteGroup();
		membersList = new FlxTypedGroup<FlxText>();
		vcr = OHUtil.createVCR();

		add(bg);
		add(tvView);
		add(tv);
		add(membersList);

		var suffix = (OHGlobal.lang != null && OHGlobal.lang.currentLanguage == 'es-pr') ? 'es' : 'en';
		var xmlText:String = null;
		try { xmlText = Paths.getTextFromFile('data/config/OHCredits/credits-' + suffix + '.xml'); }
		catch (e:Dynamic) {}

		if (xmlText != null && xmlText.length > 0)
		{
			try { data = Xml.parse(xmlText).firstElement(); }
			catch (e:Dynamic) { data = null; }
		}

		if (data == null)
			info.push({name: "Other Halloween", desc: "Credits file missing", icon: "", url: ""});
		else
			parseData();

		if (info.length == 0)
			info.push({name: "Empty", desc: "No credits found", icon: "", url: ""});

		var textY:Float = INIT_Y;
		for (i in 0...info.length)
		{
			var member = new FlxSprite(0, 0);
			if (info[i].icon != null && info[i].icon.length > 0)
			{
				try { member.loadGraphic(Paths.image('credits/' + info[i].icon)); }
				catch (e:Dynamic) { member.makeGraphic(200, 200, 0xFF333333); }
			}
			else
				member.makeGraphic(200, 200, 0xFF333333);

			member.antialiasing = ClientPrefs.data.antialiasing;
			member.ID = i;
			member.screenCenter(Y);
			member.y -= 70;
			member.alpha = 0;
			if (vcr != null) member.shader = vcr;
			member.cameras = [tvIn];
			tvView.add(member);

			var text = OHUtil.makeText(0, textY, 0, info[i].name.toUpperCase(), 28);
			text.ID = i;
			text.updateHitbox();
			text.x = FlxG.width - text.width - 40;
			text.cameras = [outView];
			membersList.add(text);
			textY += text.height + 4;
		}

		descText = OHUtil.makeText(16, 630, FlxG.width - 32, "", 32, CENTER);
		descText.screenCenter(X);
		descText.cameras = [outView];
		add(descText);

		if (membersList.members.length > 0 && membersList.members[0] != null)
			arrow = OHUtil.makeText(membersList.members[0].x + membersList.members[0].width, INIT_Y, 0, '<', 28);
		else
			arrow = OHUtil.makeText(FlxG.width - 80, INIT_Y, 0, '<', 28);
		arrow.updateHitbox();
		arrow.cameras = [outView];
		add(arrow);
		add(title);

		changeItem();
		if (tv.animation != null && tv.animation.getByName('idle') != null)
			tv.animation.play('idle');

		try { FlxG.sound.playMusic(Paths.music('menus/credits'), 0.7, false); }
		catch (e:Dynamic) {}

		super.create();
	}

	override function update(elapsed:Float)
	{
		looptime += elapsed;
		if (vcr != null) OHUtil.tickVCR(vcr, looptime);

		if (controls.BACK) OHUtil.switchState(new MainMenuState());

		if (info.length > 0 && membersList != null && membersList.members.length > 0)
		{
			if (curSelected >= 0 && curSelected < membersList.members.length
				&& membersList.members[curSelected] != null)
			{
				arrow.y = membersList.members[curSelected].y;
			}
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);
			if (controls.ACCEPT) openURL();
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		if (info.length == 0) return;
		curSelected = FlxMath.wrap(curSelected + change, 0, info.length - 1);

		if (tvView != null)
		{
			tvView.forEach(function(spr:FlxSprite)
			{
				spr.alpha = (spr.ID == curSelected) ? 1 : 0;
			});
		}

		if (FlxG.sound.music != null && info[curSelected] != null)
		{
			if (info[curSelected].name == 'Jojogamer124')
				FlxG.sound.music.fadeOut(0.8);
			else
				FlxG.sound.music.fadeIn(0.5, FlxG.sound.music.volume, 0.7);
		}

		if (descText != null && info[curSelected] != null)
		{
			descText.text = info[curSelected].desc;
			descText.screenCenter(X);
		}

		try { FlxG.sound.play(Paths.sound('menu/scroll'), 0.7); } catch (_:Dynamic) {}
	}

	function openURL()
	{
		if (info.length == 0 || curSelected < 0 || curSelected >= info.length) return;
		var url = info[curSelected].url;
		if (url != null && url != '')
			CoolUtil.browserLoad(url);
	}

	function parseData()
	{
		if (data == null) return;
		for (node in data.elements())
		{
			var name = node.get("name");
			if (name == null) name = "Unknown";
			info.push({
				name: name,
				desc: (node.get("desc") != null) ? node.get("desc") : '',
				icon: (node.get("icon") != null) ? node.get("icon") : '',
				url: (node.get("url") != null) ? node.get("url") : ''
			});
		}
	}
}
