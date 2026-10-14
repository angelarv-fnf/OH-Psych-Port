-- Pre-song rules cutscene
-- Ported from cutscene.hx

local skippable = false
local cutEnded = false

function onStartCountdown()
	if cutEnded or isStoryMode == false and seenCutscene then
		return Function_Continue
	end
	if not cutEnded then
		-- Show rules overlay
		makeLuaSprite('rulesBG', '', 0, 0)
		makeGraphic('rulesBG', screenWidth * 2, screenHeight * 2, '000000')
		setObjectCamera('rulesBG', 'camOther')
		addLuaSprite('rulesBG', true)

		makeLuaSprite('rules', 'menus/rules/marriage_rules_1', 0, 0)
		setObjectCamera('rules', 'camOther')
		setProperty('rules.alpha', 0)
		if difficultyName:lower() == 'hard' then
			setProperty('rules.color', getColorFromHex('FF0000'))
		end
		addLuaSprite('rules', true)

		local titleStr = 'Rules'
		local contStr = 'Press ENTER to continue'
		local rulesStr = 'Survive the song.\nNormal: Health does not regenerate from hits.\nHard: You have 7 lives. One miss = one life.'

		makeLuaText('rulesTitle', titleStr, 500, screenWidth - 580, 25)
		setTextSize('rulesTitle', 48)
		setTextAlignment('rulesTitle', 'right')
		setObjectCamera('rulesTitle', 'camOther')
		addLuaText('rulesTitle')

		makeLuaText('rulesText', rulesStr, 500, screenWidth - 580, 100)
		setTextSize('rulesText', 28)
		setTextAlignment('rulesText', 'right')
		setObjectCamera('rulesText', 'camOther')
		addLuaText('rulesText')

		makeLuaText('canContinue', contStr, 500, screenWidth - 580, screenHeight - 100)
		setTextSize('canContinue', 24)
		setObjectCamera('canContinue', 'camOther')
		setProperty('canContinue.visible', false)
		addLuaText('canContinue')

		doTweenAlpha('rulesIn', 'rules', 1, 1, 'linear')
		playSound('loading_screen', 0.7)
		runTimer('enableSkip', 4)

		return Function_Stop
	end
	return Function_Continue
end

function onTimerCompleted(tag)
	if tag == 'enableSkip' then
		skippable = true
		setProperty('canContinue.visible', true)
	end
end

function onUpdate(elapsed)
	if not cutEnded and skippable and (keyJustPressed('accept') or keyJustPressed('enter')) then
		cutEnded = true
		removeLuaSprite('rulesBG', true)
		removeLuaSprite('rules', true)
		removeLuaText('rulesTitle', true)
		removeLuaText('rulesText', true)
		removeLuaText('canContinue', true)
		startCountdown()
	end
end
