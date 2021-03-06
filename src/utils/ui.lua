function drawPaddedRect(x, y, w, h, ref)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- padding
	gfx.setPattern(imgPattern:getImage(5 + ref % 2))
	gfx.fillRect(x + 2, y + 2, w - 4, h - 4)
  gfx.setColor(gfx.kColorBlack)
	gfx.drawLine(x + 23, y + 2, x + 23, y + h - 3)
	gfx.drawLine(x + 2, y + h - 3, x + w - 3, y + h - 3)
end

function drawStripedRect(x, y, w, h, ref)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- stripes
	gfx.setPattern(imgPattern:getImage(1 + ref % 4))
	gfx.fillRect(x + 2, y + 2, w - 4, h - 4)
end

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
		for y = 1, puzzle.height do
			for x = 1, puzzle.width do
				if puzzle.grid[i] == 0 then
					gfx.fillRect(x + 1, y + 3, 1, 1)
				end
				i += 1
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
