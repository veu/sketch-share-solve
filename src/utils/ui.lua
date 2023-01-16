function drawRightTextRect(x, y, w, h, text)
	-- background
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(x, y, w, h)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- text
	gfx.setFont(fontText)
	local width = gfx.getTextSize(text)
	gfx.drawText(text, x + w - width - 5, y + 6)
end

function loadAvatar(data)
	local image = gfx.image.new(10, 10, gfx.kColorBlack)
	gfx.lockFocus(image)
	do
		gfx.setColor(gfx.kColorWhite)
		local i = 1
		local values = {string.byte(data, 1, 100)}
		for y = 0, 9 do
			for x = 0, 9 do
				if values[i] == 48 then
					gfx.fillRect(x, y, 1, 1)
				end
				i += 1
			end
		end
	end
	gfx.unlockFocus()

	return image
end

function saveAvatar(avatar)
	local data = table.create(100, 0)
	local i = 1
	for y = 0, 9 do
		for x = 0, 9 do
			data[i] = avatar:sample(x, y) == playdate.graphics.kColorBlack and 1 or 0
			i += 1
		end
	end

	return table.concat(data)
end

function createAvatarPreview(puzzle)
	if not puzzle then
		return nil
	end

	local image = gfx.image.new(puzzle.width, puzzle.height, gfx.kColorBlack)
	gfx.lockFocus(image)
	do
		gfx.setColor(gfx.kColorWhite)
		for y = 1, puzzle.height do
			for x = 1, puzzle.width do
				local index = x - 1 + (y - 1) * puzzle.width + 1
				if puzzle.grid[index] == 0 then
					gfx.fillRect(x - 1, y - 1, 1, 1)
				end
			end
		end
	end
	gfx.unlockFocus()

	return image
end

function createPuzzlePreview(puzzle)
	local image = gfx.image.new(19, 19, gfx.kColorBlack)
	gfx.lockFocus(image)
	do
		imgBox:drawImage(5, 0, 0)
		gfx.setColor(gfx.kColorWhite)
		local i = 1
		if puzzle.rotation == 1 then
			for y = 1, puzzle.height do
				for x = 1, puzzle.width do
					if puzzle.grid[i] == 0 then
						gfx.fillRect(y + 3, puzzle.width - x + 2, 1, 1)
					end
					i += 1
				end
			end
		elseif puzzle.rotation == 2 then
			for y = 1, puzzle.height do
				for x = 1, puzzle.width do
					if puzzle.grid[i] == 0 then
						gfx.fillRect(puzzle.height - y + 5, x + 1, 1, 1)
					end
					i += 1
				end
			end
		else
			for y = 1, puzzle.height do
				for x = 1, puzzle.width do
					if puzzle.grid[i] == 0 then
						gfx.fillRect(x + 1, y + 3, 1, 1)
					end
					i += 1
				end
			end
		end
	end
	gfx.unlockFocus()

	return image
end

function createHintStylePreview(hintStyle)
	local image = gfx.image.new(19, 19, gfx.kColorWhite)
	gfx.lockFocus(image)
	do
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(1, 1, 17, 17)
		imgGrid:drawImage(NUM_STYLE_OFFSETS[hintStyle] + 1, 2, 2)
	end
	gfx.unlockFocus(image)

	return image
end
