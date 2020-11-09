local pressCounter = 0
local PRESSED = {}

function handleCursorDir(fill, cross, button, update)
	if playdate.buttonJustPressed(button) then
		pressCounter = 0
		update()
		if PRESSED[playdate.kButtonA] then
			fill(false)
		elseif PRESSED[playdate.kButtonB] then
			cross(false)
		end
	elseif playdate.buttonIsPressed(button) then
		pressCounter += 1
		if pressCounter > 5 and pressCounter % 5 == 0 then
			update()
			if PRESSED[playdate.kButtonA] then
				fill(false)
			elseif PRESSED[playdate.kButtonB] then
				cross(false)
			end
		end
	elseif playdate.buttonJustReleased(button) then
		pressCounter = 0
	end
end

function handleFill(fill)
	if playdate.buttonJustPressed(playdate.kButtonA) then
		PRESSED[playdate.kButtonA] = true
		fill(true)
	end
	if playdate.buttonJustReleased(playdate.kButtonA) then
		PRESSED[playdate.kButtonA] = false
	end
end

function handleCross(cross)
	if playdate.buttonJustPressed(playdate.kButtonB) then
		PRESSED[playdate.kButtonB] = true
		cross(true)
	end
	if playdate.buttonJustReleased(playdate.kButtonB) then
		PRESSED[playdate.kButtonB] = false
	end
end