-- Marriage or Disparage - main events (ported from Codename events.hx)
-- Place in: data/marriage-or-disparage/events.lua  OR  songs/marriage-or-disparage/events.lua

local sceneCamX, sceneCamY = 0, 0
local usingCustomCam = false
local phaseTwo = false
local colored = false
local dying = false

-- Subtitles (English fallback; swap if you add lang later)
local subs = {
	"Look at me...",
	"I'm not the same...",
	"You left me alone...",
	"With all this pain...",
	"Why did you do this?",
	"I trusted you...",
	"",
	"It's too late..."
}

local strumPlayer = {}
local strumOpponent = {}
local danceLeft = false

function onCreate()
	-- Phase 2 props (hidden until beat 592)
	makeLuaSprite('bg2', 'stages/house-lime/phase2-bg', 0, 0)
	setScrollFactor('bg2', 0, 0)
	setGraphicSize('bg2', screenWidth, 0)
	setObjectCamera('bg2', 'camGame')
	setProperty('bg2.visible', false)
	addLuaSprite('bg2', false)

	makeLuaSprite('hairWeb', 'stages/house-lime/hair-web', 0, 0)
	setScrollFactor('hairWeb', 0, 0)
	scaleObject('hairWeb', 0.8, 0.8)
	screenCenter('hairWeb')
	setObjectCamera('hairWeb', 'camHUD')
	setProperty('hairWeb.visible', false)
	addLuaSprite('hairWeb', true)

	-- Song title card
	makeLuaSprite('songTitle', 'game/props/songtitles/MoD', 0, 0)
	setScrollFactor('songTitle', 0, 0)
	scaleObject('songTitle', 0.8, 0.8)
	screenCenter('songTitle')
	setObjectCamera('songTitle', 'camHUD')
	setProperty('songTitle.alpha', 0)
	addLuaSprite('songTitle', true)

	-- Subtitles
	makeLuaText('subs', '', 1000, 0, 600)
	setTextSize('subs', 36)
	setTextAlignment('subs', 'center')
	setTextBorder('subs', 2, '000000')
	setObjectCamera('subs', 'camOther')
	screenCenter('subs', 'x')
	addLuaText('subs')
end

function onCreatePost()
	-- Phase 2 characters (lime-two / max7act2) – only if they exist
	-- Psych uses changeCharacter events or addCharacterToList; we toggle visibility via alpha
end

function onSongStart()
	sceneCamX = getProperty('camFollow.x')
	sceneCamY = getProperty('camFollow.y')
end

function onBeatHit()
	if curBeat == 8 then
		-- Cache strum positions for modchart
		for i = 0, 3 do
			strumPlayer[i] = {
				x = getPropertyFromGroup('playerStrums', i, 'x'),
				y = getPropertyFromGroup('playerStrums', i, 'y')
			}
			strumOpponent[i] = {
				x = getPropertyFromGroup('opponentStrums', i, 'x'),
				y = getPropertyFromGroup('opponentStrums', i, 'y')
			}
		end
	end

	if curBeat == 32 then
		setProperty('camHUD.visible', false)
		setProperty('boyfriend.alpha', 0)
		setProperty('defaultCamZoom', 1.4)
		setProperty('camFollow.x', 980)
		setProperty('camFollow.y', 650)
		usingCustomCam = true
	elseif curBeat == 38 then
		doTweenX('camMoveX', 'camFollow', getProperty('camFollow.x') - 620, 6, 'quadInOut')
		doTweenY('camMoveY', 'camFollow', getProperty('camFollow.y') - 250, 6, 'quadInOut')
	elseif curBeat == 56 then
		setProperty('boyfriend.alpha', 1)
		doTweenX('camMoveX2', 'camFollow', getProperty('camFollow.x') + 300, 2, 'sineInOut')
		doTweenY('camZoomBack', 'camGame', 1, 2, 'sineInOut')
		setProperty('defaultCamZoom', 1)
	elseif curBeat == 320 then
		setProperty('camZooming', true)
	elseif curBeat == 448 then
		setProperty('camHUD.visible', false)
		setProperty('camGame.visible', false)
	elseif curBeat == 456 then
		setProperty('camHUD.visible', true)
		setProperty('camGame.visible', true)
		setProperty('camFollow.x', 980 - 600)
		setProperty('camFollow.y', 650 - 250)
		setProperty('camGame.zoom', 1.5)
		setProperty('camGame.angle', -15)
		doTweenY('zoomBack', 'camGame', 1, 5, 'sineInOut')
		doTweenAngle('angleBack', 'camGame', 0, 5, 'sineInOut')
	elseif curBeat == 472 then
		usingCustomCam = false
	elseif curBeat == 524 then
		setProperty('camZooming', true)
	elseif curBeat == 528 then
		cameraFlash('camHUD', 'FF00FF', 0.6)
		setColorStrums(false)
		jumpNotes()
	elseif curBeat == 588 then
		resetNotes()
		setColorStrums(true)
	elseif curBeat == 591 then
		doTweenY('preZoom', 'camGame', 0.7, 0.8, 'quadInOut')
		doTweenAngle('preAngle', 'camGame', 10, 0.8, 'quadInOut')
	elseif curBeat == 592 then
		-- Phase 2
		cameraFlash('camHUD', 'FF00FF', 2)
		cancelTween('preZoom')
		cancelTween('preAngle')
		setProperty('camGame.zoom', getProperty('defaultCamZoom'))
		setProperty('camGame.angle', 0)
		setProperty('bg2.visible', true)
		setProperty('hairWeb.visible', true)
		doTweenY('bg2Rise', 'bg2', getProperty('bg2.y') - 2600, 34, 'linear')
		phaseTwo = true
		-- Swap characters if available
		triggerEvent('Change Character', 'dad', 'lime-two')
		triggerEvent('Change Character', 'bf', 'max7act2')
	elseif curBeat == 688 then
		doTweenAlpha('strumsOut0', 'playerStrums.members[0]', 0.01, 12)
		doTweenAlpha('strumsOut1', 'playerStrums.members[1]', 0.01, 12)
		doTweenAlpha('strumsOut2', 'playerStrums.members[2]', 0.01, 12)
		doTweenAlpha('strumsOut3', 'playerStrums.members[3]', 0.01, 12)
		for i = 0, 3 do
			noteTweenAlpha('oppFade'..i, i, 0.01, 12)
		end
	elseif curBeat == 720 then
		setProperty('camHUD.visible', false)
		setProperty('camGame.visible', false)
	end
end

function onStepHit()
	-- Subtitles
	if curStep == 150 then setSubtitle(1)
	elseif curStep == 168 then setSubtitle(2)
	elseif curStep == 188 then setSubtitle(3)
	elseif curStep == 205 then setSubtitle(4)
	elseif curStep == 222 then setSubtitle(5)
	elseif curStep == 239 then setSubtitle(6)
	elseif curStep == 213 or curStep == 255 or curStep == 1823 then setSubtitle(7)
	elseif curStep == 256 then
		setSubtitle(7)
		setProperty('camHUD.visible', true)
		cameraShake('camHUD', 0.02, 0.2)
		cameraShake('camGame', 0.01, 0.2)
		doTweenAlpha('titleIn', 'songTitle', 1, 0.5, 'circOut')
		runTimer('titleOut', 3)
	elseif curStep == 1808 then
		setSubtitle(8)
	end
end

function onTimerCompleted(tag)
	if tag == 'titleOut' then
		doTweenAlpha('titleFade', 'songTitle', 0, 1, 'sineIn')
		doTweenAngle('titleSpin', 'songTitle', 10, 1, 'sineIn')
		doTweenX('titleScaleX', 'songTitle.scale', 0.3, 1, 'sineIn')
		doTweenY('titleScaleY', 'songTitle.scale', 0.3, 1, 'sineIn')
	end
end

function setSubtitle(idx)
	if subs[idx] then
		setTextString('subs', subs[idx])
		screenCenter('subs', 'x')
	end
end

function setColorStrums(reset)
	colored = not reset
	-- Psych doesn't expose colorTransform the same way; approximate with note alpha/tint via events if needed
end

function jumpNotes()
	local beatLen = (60 / bpm) * 2
	for i = 0, 3 do
		local delay = i * 0.1
		noteTweenY('jumpP'..i, i + 4, getPropertyFromGroup('playerStrums', i, 'y') + 50, beatLen, 'sineInOut')
		noteTweenY('jumpO'..i, i, getPropertyFromGroup('opponentStrums', i, 'y') + 50, beatLen, 'sineInOut')
		-- Swap X positions (ping-pong style approximated with one swap)
		noteTweenX('swapP'..i, i + 4, strumOpponent[i].x, beatLen * 2, 'sineInOut')
		noteTweenX('swapO'..i, i, strumPlayer[i].x, beatLen * 2, 'sineInOut')
	end
end

function resetNotes()
	for i = 0, 3 do
		cancelTween('jumpP'..i)
		cancelTween('jumpO'..i)
		cancelTween('swapP'..i)
		cancelTween('swapO'..i)
		noteTweenX('resetPX'..i, i + 4, strumPlayer[i].x, 0.1, 'circOut')
		noteTweenY('resetPY'..i, i + 4, strumPlayer[i].y, 0.1, 'circOut')
		noteTweenX('resetOX'..i, i, strumOpponent[i].x, 0.1, 'circOut')
		noteTweenY('resetOY'..i, i, strumOpponent[i].y, 0.1, 'circOut')
	end
end
