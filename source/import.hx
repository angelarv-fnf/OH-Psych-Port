#if !macro
// Discord API
#if DISCORD_ALLOWED
import backend.Discord;
#end

// Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.Paths;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;

#if flxanimate
import flxanimate.*;
#end

// Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.addons.display.FlxRuntimeShader;

// Other Halloween
import backend.OHGlobal;
import backend.OHUtil;
import backend.LanguageManager;

import other.BetaWarningState;
import other.TitleState;
import other.MainMenuState;
import other.FreeplayState;
import other.CreditsState;
import other.StoryMenuState;
import other.NoCheatingState;
import other.OHOptions;
import other.OHLanguage;
import other.OHExMode;
import other.OHExtras;
import other.OHStats;
import other.Otherpedia;
import other.OHGallery;

import substates.OHPauseSubState;
import substates.OHGameOverSubstate;

using StringTools;
#end
