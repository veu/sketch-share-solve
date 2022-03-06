class("GridNumbersTop").extends(gfx.sprite)

function GridNumbersTop:init()
	GridNumbersTop.super.init(self, gfx.image.new(CELL * 15 + 1, TOP_NUMBER_HEIGHT * 5))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS)
end

function GridNumbersTop:enter(puzzle, gridNumbers, doneNumbers, x, y, hintStyle)
	self.gridNumbers = gridNumbers
	self.doneNumbers = doneNumbers
	self.gridX = x
	self.gridY = y
	self.hintStyle = hintStyle

	self:moveTo(
		GRID_OFFSET_X + CELL * (15 - puzzle.width),
		0
	)
	self:add()
	self:redraw()
end

function GridNumbersTop:updateForPosition()
	self:redrawPosition()
	if not self.cursorHidden then
		self:redrawCursor(self.gridX)
	end
end

function GridNumbersTop:updateHintStyle(hintStyle)
	self.hintStyle = hintStyle
	self:redraw()
end

function GridNumbersTop:leave()
	self:remove()
end

function GridNumbersTop:setCursor(x, y)
	if not self.cursorHidden and self.gridX ~= x then
		self:redrawCursor(self.gridX, true)
		self:redrawCursor(x)
	end

	self.gridX = x
	self.gridY = y
end

function GridNumbersTop:hideCursor()
	self.cursorHidden = true
	self:redraw()
end

function GridNumbersTop:redraw()
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(0, GRID_OFFSET_Y)

		-- numbers
		for x, numbers in ipairs(self.gridNumbers.top) do
			local done = self.doneNumbers.top[x]
			local lenNumbers = #numbers
			for i, v in ipairs(numbers) do
				imgGrid:drawImage(
					NUM_STYLE_OFFSETS[done[i] and self.hintStyle or 1] + v,
					CELL * (x - 1) + 1,
					TOP_NUMBER_HEIGHT * (i - 1 - lenNumbers) - 2
				)
			end
		end

		-- cursor
		gfx.setColor(gfx.kColorBlack)
		if not self.cursorHidden then
			gfx.drawLine(CELL * self.gridX - CELL, CELL * -5 + 11, CELL * self.gridX - CELL, -3)
			gfx.drawLine(CELL * self.gridX, CELL * -5 + 11, CELL * self.gridX, -3)
		end
	end
	gfx.unlockFocus()
end

function GridNumbersTop:redrawPosition()
	gfx.pushContext(self:getImage())
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(
		CELL * (self.gridX - 1),
		0,
		CELL + 1,
		CELL * 4 + 7
	)
	gfx.setDrawOffset(0, GRID_OFFSET_Y)
	do
		local numbers = self.gridNumbers.top[self.gridX]
		local done = self.doneNumbers.top[self.gridX]
		local lenNumbers = #numbers
		for i, v in ipairs(numbers) do
			imgGrid:drawImage(
				NUM_STYLE_OFFSETS[done[i] and self.hintStyle or 1] + v,
				CELL * (self.gridX - 1) + 1,
				TOP_NUMBER_HEIGHT * (i - 1 - lenNumbers) - 2
			)
		end
	end
	gfx.popContext()
end

function GridNumbersTop:redrawCursor(gridX, hide)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(0, GRID_OFFSET_Y)
		gfx.setColor(hide and gfx.kColorClear or gfx.kColorBlack)
		gfx.drawLine(CELL * gridX - CELL, CELL * -5 + 11, CELL * gridX - CELL, -3)
		gfx.drawLine(CELL * gridX, CELL * -5 + 11, CELL * gridX, -3)
	end
	gfx.unlockFocus()
end
