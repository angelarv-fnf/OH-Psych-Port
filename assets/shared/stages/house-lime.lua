-- Stage: house-lime
-- Filename MUST be house-lime.lua to match house-lime.json (avoids Unexpected HouseLime)
-- Paths match images/stages/house-lime/

function onCreate()
	makeLuaSprite('Highway', 'stages/house-lime/Highway', -492, -298)
	setLuaSpriteScrollFactor('Highway', 1, 1)
	addLuaSprite('Highway', false)

	makeLuaSprite('wall', 'stages/house-lime/wall', -513, -363)
	setLuaSpriteScrollFactor('wall', 1, 1)
	addLuaSprite('wall', false)

	makeLuaSprite('ground', 'stages/house-lime/ground', -532, 429)
	setLuaSpriteScrollFactor('ground', 1, 1)
	addLuaSprite('ground', false)

	makeLuaSprite('frontmoto', 'stages/house-lime/frontmoto', -319, 640)
	setLuaSpriteScrollFactor('frontmoto', 1, 1)
	addLuaSprite('frontmoto', true) -- foreground
end

function onCreatePost()
	setProperty('gf.visible', false)

	-- Scale / position overrides from original
	setProperty('dad.scale.x', 0.85)
	setProperty('dad.scale.y', 0.85)
	setProperty('dad.x', 82)
	setProperty('dad.y', 77)

	setProperty('boyfriend.scale.x', 1.3)
	setProperty('boyfriend.scale.y', 1.3)
	setProperty('boyfriend.x', 905)
	setProperty('boyfriend.y', 190)
end

function onUpdate(elapsed)
	-- Dynamic zoom: closer when camera is on opponent
	local midOpp = getMidpointX('dad')
	local midBf = getMidpointX('boyfriend')
	local camX = getProperty('camFollow.x')
	if math.abs(camX - midOpp) < math.abs(camX - midBf) then
		setProperty('defaultCamZoom', 1.2)
	else
		setProperty('defaultCamZoom', 1.0)
	end
end
