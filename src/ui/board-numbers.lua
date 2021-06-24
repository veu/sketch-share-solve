local gfx <const> = playdate.graphics

class("BoardNumbers").extends(gfx.sprite)

function BoardNumbers:init()
	BoardNumbers.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(Z_INDEX_BOARD_NUMBERS)
end

function BoardNumbers:enter(level, solution, crossed)
	self.level = level
	self.gridNumbers = Numbers(level, level.grid)
	self.solutionNumbers = Numbers(level, solution)
	self.doneNumbers = DoneNumbers(level, self.gridNumbers, self.solutionNumbers, crossed)

	self:add()
	self:redraw()
end

function BoardNumbers:leave()
	self:remove()
end

function BoardNumbers:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontGrid)
		self:drawLeft()
		self:drawTop()
	end
	gfx.unlockFocus()
	self:markDirty()
end

local NUM_MAP = {
	[0] = "0", [1] = "1", [2] = "2", [3] = "3",
	[4] = "4", [5] = "5", [6] = "6", [7] = "7",
	[8] = "8", [9] = "9", [10] = "A", [11] = "B",
	[12] = "C", [13] = "D", [14] = "E", [15] = "F",
}

function BoardNumbers:drawLeft()
	for y, numbers in pairs(self.gridNumbers.left) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				self.doneNumbers.left[y][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
				CELL * (i + BOARD_OFFSET_X - 1 - rawlen(numbers)),
				CELL * (y + BOARD_OFFSET_Y - 1) + 1
			)
		end
	end
	gfx.setDitherPattern(0.9)
	for y = 0, rawlen(self.gridNumbers.left) do
		gfx.drawLine(
			CELL * (BOARD_OFFSET_X - 8), CELL * (y + BOARD_OFFSET_Y),
			CELL * (BOARD_OFFSET_X), CELL * (y + BOARD_OFFSET_Y))
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end

function BoardNumbers:drawTop()
	for x, numbers in pairs(self.gridNumbers.top) do
		for i, v in pairs(numbers) do
			gfx.drawText(
				self.doneNumbers.top[x][i] and NUM_MAP[v] or "*" .. NUM_MAP[v] .. "*",
				CELL * (x + BOARD_OFFSET_X - 1) + 1,
				CELL * BOARD_OFFSET_Y + 14 * (i - 1 - rawlen(numbers)) - 1
				)
		end
	end
	gfx.setDitherPattern(0.8)
	for x = 0, rawlen(self.gridNumbers.top) do
		gfx.drawLine(
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y - 5),
			CELL * (x + BOARD_OFFSET_X), CELL * (BOARD_OFFSET_Y)
		)
	end
	gfx.setDitherPattern(gfx.image.kDitherTypeNone)
end
