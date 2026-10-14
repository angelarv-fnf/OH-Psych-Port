-- Nightmare mode helper (Normal difficulty)
-- Ported from nightmare.hx – max health start, neutralize health gain on hit

if difficultyName:lower() ~= 'normal' then return end

function onCreatePost()
	setProperty('health', 2) -- max
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	-- Neutralize the health that was just gained
	-- Psych applies healthGain after the callback in some versions;
	-- subtract a small fixed amount to approximate neutralization
	local hg = getPropertyFromGroup('notes', id, 'hitHealth') or 0.023
	setProperty('health', getProperty('health') - hg)
end
