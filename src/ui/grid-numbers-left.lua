local gfx <const> = playdate.graphics

class("GridNumbersLeft").extends(gfx.sprite)

function GridNumbersLeft:init()
	GridNumbersLeft.super.init(self, gfx.image.new(CELL * 8, CELL * 10 + 1))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS)
end

function GridNumbersLeft:enter(puzzle, gridNumbers, doneNumbers, x, y, showHints, hintStyle)
	self.puzzle = puzzle
	self.gridNumbers = gridNumbers
	self.doneNumbers = doneNumbers
	self.gridX = x
	self.gridY = y
	self.showHints = showHints
	self.hintStyle = hintStyle

	self:moveTo(SEPARATOR_WIDTH, GRID_OFFSET_Y)
	self:add()
	self:redraw()
end

function GridNumbersLeft:updateAll()
	self:redraw()
	if not self.cursorHidden then
		self:redrawLeftCursor(self.gridY)
	end
end

function GridNumbersLeft:updateForPosition()
	self:redrawPosition()
	if not self.cursorHidden then
		self:redrawLeftCursor(self.gridY)
	end
end

function GridNumbersLeft:updateHintStyle(hintStyle)
	self.hintStyle = hintStyle
	self:redraw()
end

function GridNumbersLeft:leave()
	self:remove()
end

function GridNumbersLeft:setCursor(x, y)
	if not self.cursorHidden and self.gridY ~= y then
		self:redrawLeftCursor(self.gridY, true)
		self:redrawLeftCursor(y)
	end

	self.gridX = x
	self.gridY = y
end

function GridNumbersLeft:hideCursor()
	self.cursorHidden = true
	self:redraw()
end

function GridNumbersLeft:redraw()
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)

		-- numbers
		local gridNumbers <const> = self.gridNumbers.left
		local doneNumbers <const> = self.doneNumbers.left
		local doneNumbersLine <const> = self.doneNumbers.leftLine
		for y = 1, #gridNumbers do
			local numbers <const> = gridNumbers[y]
			local done <const> = doneNumbers[y]
			local doneLine <const> = doneNumbersLine[y]
			local lenNumbers <const> = #numbers
			for i = 1, lenNumbers do
				local isDone <const> =
					self.showHints ~= HINTS_ID_OFF and doneLine or
					self.showHints == HINTS_ID_BLOCKS and done[i]
				imgGrid:drawImage(
					NUM_STYLE_OFFSETS[isDone and self.hintStyle or 1] + numbers[i],
					(CELL - 1) * (i - 1 - lenNumbers) - 1,
					CELL * (y - 1) + 1
				)
			end
		end

		-- cursor
		gfx.setColor(gfx.kColorBlack)
		if not self.cursorHidden then
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY - CELL, -3, CELL * self.gridY - CELL)
			gfx.drawLine(CELL * -8 + 3, CELL * self.gridY, -3, CELL * self.gridY)
		end
	end
	gfx.unlockFocus()
end

function GridNumbersLeft:redrawPosition()
	gfx.lockFocus(self:getImage())
	gfx.setColor(gfx.kColorClear)
	gfx.fillRect(0, CELL * (self.gridY - 1), CELL * 8, CELL + 1)
	gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)
	do
		local y <const> = self.gridY
		local numbers <const> = self.gridNumbers.left[y]
		local done <const> = self.doneNumbers.left[y]
		local doneLine <const> = self.doneNumbers.leftLine[y]
		local lenNumbers <const> = #numbers
		for i = 1, lenNumbers do
			local isDone <const> =
				self.showHints ~= HINTS_ID_OFF and doneLine or
				self.showHints == HINTS_ID_BLOCKS and done[i]
			imgGrid:drawImage(
				NUM_STYLE_OFFSETS[isDone and self.hintStyle or 1] + numbers[i],
				(CELL - 1) * (i - 1 - lenNumbers) - 1,
				CELL * (y - 1) + 1
			)
		end
	end
	gfx.unlockFocus()
end

function GridNumbersLeft:redrawLeftCursor(gridY, hide)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(GRID_OFFSET_X - SEPARATOR_WIDTH + CELL * (15 - self.puzzle.width), 0)
		gfx.setColor(hide and gfx.kColorClear or gfx.kColorBlack)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY - CELL, -3, CELL * gridY - CELL)
		gfx.drawLine(CELL * -8 + 3, CELL * gridY, -3, CELL * gridY)
	end
	gfx.unlockFocus()
end
