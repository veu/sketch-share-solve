local pressCounter = 0

function handleCursorDir(fill, cross, button, update)
	if playdate.buttonJustPressed(button) then
		pressCounter = 0
		update(false)
		if playdate.buttonIsPressed(playdate.kButtonA) then
			fill(false)
		elseif playdate.buttonIsPressed(playdate.kButtonB) then
			cross(false)
		end
	elseif playdate.buttonIsPressed(button) then
		pressCounter += 1
		if pressCounter > 4 and pressCounter % 4 == 0 then
			update(
				playdate.buttonIsPressed(playdate.kButtonA) or playdate.buttonIsPressed(playdate.kButtonB)
			)
			if playdate.buttonIsPressed(playdate.kButtonA) then
				fill(false)
			elseif playdate.buttonIsPressed(playdate.kButtonB) then
				cross(false)
			end
		end
	elseif playdate.buttonJustReleased(button) then
		pressCounter = 0
	end
end

function handleFill(fill)
	if playdate.buttonJustPressed(playdate.kButtonA) then
		fill(true)
	end
end

function handleCross(cross)
	if playdate.buttonJustPressed(playdate.kButtonB) then
		cross(true)
	end
end
