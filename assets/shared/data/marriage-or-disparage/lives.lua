-- Lives system (Hard difficulty only)
-- Ported from lives.hx – 7 life points, miss = lose one, 8th miss = game over

if difficultyName:lower() ~= 'hard' then return end

local baseIconScale = 0.8
local iconScale = 0.8
local lives = 1
local maxLives = 7

function onCreate()
	setProperty('ghostTapping', false)
end

function onCreatePost()
	local yPos = downscroll and 165 or 200

	makeLuaSprite('missBar', 'game/props/miss_bar', 0, screenHeight - yPos)
	setObjectCamera('missBar', 'camHUD')
	screenCenter('missBar', 'x')
	addLuaSprite('missBar', true)

	for i = 1, maxLives do
		local tag = 'life'..i
		makeLuaSprite(tag, 'game/props/lifepoint', 0, 0)
		scaleObject(tag, 0.9, 0.9)
		setObjectCamera(tag, 'camHUD')
		setProperty(tag..'.x', getProperty('missBar.x') + (getProperty(tag..'.width') + 8) * i + 25)
		setProperty(tag..'.y', getProperty('missBar.y') + 70)
		addLuaSprite(tag, true)
	end

	-- Icons
	makeLuaSprite('bfIcon', 'icons/icon-maxseven', 0, 0)
	setObjectCamera('bfIcon', 'camHUD')
	scaleObject('bfIcon', 0.8, 0.8)
	setProperty('bfIcon.x', getProperty('missBar.x') + getProperty('missBar.width') + 10)
	setProperty('bfIcon.y', getProperty('missBar.y') + (downscroll and 30 or 50))
	setProperty('bfIcon.flipX', true)
	addLuaSprite('bfIcon', true)

	makeLuaSprite('gfIcon', 'icons/icon-limerence', 0, 0)
	setObjectCamera('gfIcon', 'camHUD')
	scaleObject('gfIcon', 0.8, 0.8)
	setProperty('gfIcon.x', getProperty('missBar.x') - 130)
	setProperty('gfIcon.y', getProperty('missBar.y') + (downscroll and 30 or 50))
	addLuaSprite('gfIcon', true)

	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	setProperty('healthBar.visible', false)
	setProperty('healthBarBG.visible', false)

	setProperty('scoreTxt.y', getProperty('scoreTxt.y') - (downscroll and 150 or 120))
	setProperty('scoreTxt.x', getProperty('scoreTxt.x') - 150)
end

function noteMiss(id, direction, noteType, isSustainNote)
	playSound('MoD/onelife_out', 1)
	cameraShake('camHUD', 0.02, 0.1)

	local tag = 'life'..lives
	doTweenY(tag..'Fall', tag, getProperty(tag..'.y') + 100, 0.5, 'circOut')
	doTweenAlpha(tag..'Fade', tag, 0, 0.5, 'circOut')

	lives = lives + 1
	if lives > maxLives then
		setProperty('health', -1) -- force game over
	end
end

function onBeatHit()
	iconScale = 1.0
end

function onUpdatePost(elapsed)
	iconScale = lerp(iconScale, baseIconScale, 0.15)
	scaleObject('bfIcon', iconScale, iconScale)
	scaleObject('gfIcon', iconScale, iconScale)
end

function lerp(a, b, t)
	return a + (b - a) * t
end
