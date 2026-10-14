package backend;

import haxe.Json;
import flixel.FlxG;

/**
 * Simple language tree loader.
 * Expects JSON files at:
 *   data/config/language/en-us.json
 *   data/config/language/es-pr.json
 *
 * Structure example:
 * {
 *   "menus": {
 *     "Title": { "introTexts": [...], "enterText": "..." },
 *     "MainMenu": { "optionShit": [...], "wipSub": [...] },
 *     ...
 *   },
 *   "subtitles": { ... }
 * }
 */
class LanguageManager
{
	public var currentLanguage:String = 'en-us';
	public var languageTree:Dynamic = {};

	public function new(langCode:String = 'en-us')
	{
		setLanguage(langCode);
	}

	public function setLanguage(code:String):Void
	{
		currentLanguage = code;
		var path = 'data/config/language/' + code + '.json';
		try
		{
			var raw = Paths.getTextFromFile(path);
			if (raw != null && raw.length > 0)
			{
				languageTree = Json.parse(raw);
				trace("LanguageManager: loaded " + code);
				return;
			}
		}
		catch (e:Dynamic)
		{
			trace("LanguageManager: failed to load " + code + " -> " + e);
		}

		// Minimal fallback so the game never crashes
		languageTree = getFallbackTree(code);
	}

	function getFallbackTree(code:String):Dynamic
	{
		var isEs = (code == 'es-pr');
		return {
			menus: {
				Title: {
					introTexts: isEs
						? ["Juego original por\n*FunkinCrew*", "Motor Codename por\n*YoshiCrafter29*", "Mod creado por\n*Sexy Team*", "Dirigido por\n*EstudiOmega*", "esto", "es"]
						: ["Original Game by\n*FunkinCrew*", "Codename Engine by\n*YoshiCrafter29*", "Mod created by\n*Sexy Team*", "Directed by\n*EstudiOmega*", "this", "is"],
					enterText: isEs ? "Presiona ENTER para comenzar" : "Press ENTER to Start"
				},
				MainMenu: {
					optionShit: isEs
						? ["modo historia", "freeplay", "opciones", "créditos", "tienda", "extras"]
						: ["story mode", "freeplay", "options", "credits", "shop", "extras"],
					wipSub: isEs
						? ["¡Esto está en desarrollo\ntonto!", "¡La tienda está cerrada\nforastero!", "Debes completar\nlo siguiente\npara desbloquear:|Completa la canción RED"]
						: ["This is on Development\nyou fool!", "The shop is closed\nstranger!", "You must complete\nthe following\nto unlock this:|Complete the song RED"]
				},
				Options: {
					optionShit: isEs ? ["idioma", "Modo Exp.", "otras opciones"] : ["language", "Ex. Mode", "other options"],
					exMode: {
						msg: isEs
							? ["Advertencia", "Esta opción permite ver contenido explícito (como *GORE*, *VIOLENCIA*, etc) que no es adecuado para todos.\n", "Sin embargo, esto no desactiva cosas de miedo como los Jumpscares."]
							: ["Warning", "This option allows you to see explicit content (like *GORE*, *VIOLENCE*, etc) that are not suitable for everyone.\n", "However, this doesn't disable scary things like Jumpscares."]
					}
				},
				Extras: {
					optionShit: isEs ? ["logros", "estadísticas", "galería", "otherpedia"] : ["achievements", "statistics", "gallery", "otherpedia"],
					otherpedia: {eats: isEs ? "Come" : "Eats", loves: isEs ? "Ama" : "Loves", hates: isEs ? "Odia" : "Hates", origin: isEs ? "Origen" : "Origin"},
					stats: {accu: isEs ? "Precisión" : "Accuracy", combo: isEs ? "Puntuación" : "Score", misses: isEs ? "Fallos" : "Misses"}
				},
				Freeplay: {
					diffDesc: {
						normal: isEs ? "Dificultad normal" : "Normal difficulty",
						hard: isEs ? "Dificultad difícil" : "Hard difficulty"
					}
				},
				Warning: {
					msg: isEs
						? "Este mod contiene contenido explícito / gore.\nPresiona ENTER para activar el Modo Explícito\no ESCAPE para dejarlo desactivado."
						: "This mod contains explicit / gore content.\nPress ENTER to enable Explicit Mode\nor ESCAPE to keep it disabled."
				},
				Pause: {
					optionShit: isEs ? ["Continuar", "Reiniciar", "Opciones", "Salir"] : ["Resume", "Restart", "Options", "Exit"]
				}
			},
			subtitles: {
				MoD_gameover: {
					gore: isEs ? ["..."] : ["..."],
					nogore: isEs ? ["Hola...", "Esto es un game over."] : ["Hello...", "This is a game over."]
				}
			}
		};
	}
}
