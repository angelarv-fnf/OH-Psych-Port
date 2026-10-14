-- Custom limerence health bar (Normal difficulty only)
-- Ported from healthbar.hx

if difficultyName:lower() ~= 'normal' then return end

local baseIconScale = 0.8
local iconScale = 0.8

function onCreatePost()
	-- Custom bar graphic
	makeLuaSprite('limeHealth', 'game/props/limerence_bar', 0, screenHeight - 145)
	setObjectCamera('limeHealth', 'camHUD')
	screenCenter('limeHealth', 'x')
	addLuaSprite('limeHealth', true)

	-- Custom icons
	makeLuaSprite('bfIcon', 'icons/icon-maxseven', 0, 0)
	-- Psych icons are usually icon-name; fallback path
	-- Using load from healthicon name if available
	setObjectCamera('bfIcon', 'camHUD')
	scaleObject('bfIcon', 0.8, 0.8)
	setProperty('bfIcon.x', getProperty('limeHealth.x') + getProperty('limeHealth.width') + 10)
	setProperty('bfIcon.y', getProperty('limeHealth.y') - 10)
	setProperty('bfIcon.flipX', true)
	addLuaSprite('bfIcon', true)

	makeLuaSprite('gfIcon', 'icons/icon-limerence', 0, 0)
	setObjectCamera('gfIcon', 'camHUD')
	scaleObject('gfIcon', 0.8, 0.8)
	setProperty('gfIcon.x', getProperty('limeHealth.x') - 155)
	setProperty('gfIcon.y', getProperty('limeHealth.y') - 10)
	addLuaSprite('gfIcon', true)

	-- Hide default icons
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)

	-- Shift health bar / score text up a bit
	if downscroll then
		setProperty('healthBar.y', getProperty('healthBar.y') - 18)
		setProperty('healthBarBG.y', getProperty('healthBarBG.y') - 18)
	else
		setProperty('healthBar.y', getProperty('healthBar.y') - 11)
		setProperty('healthBarBG.y', getProperty('healthBarBG.y') - 11)
	end

	setProperty('scoreTxt.y', getProperty('scoreTxt.y') - 120)
end

function onBeatHit()
	iconScale = 1.0
	if curBeat == 688 then
		doTweenAlpha('hbFade', 'healthBar', 0, 12)
		doTweenAlpha('hbbgFade', 'healthBarBG', 0, 12)
		doTweenAlpha('bfIconFade', 'bfIcon', 0, 12)
		doTweenAlpha('gfIconFade', 'gfIcon', 0, 12)
		doTweenAlpha('limeFade', 'limeHealth', 0, 12)
	end
end

function onUpdatePost(elapsed)
	iconScale = lerp(iconScale, baseIconScale, 0.15)
	scaleObject('bfIcon', iconScale, iconScale)
	scaleObject('gfIcon', iconScale, iconScale)
end

function lerp(a, b, t)
	return a + (b - a) * t
end
