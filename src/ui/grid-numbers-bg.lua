local gfx <const> = playdate.graphics

class("GridNumbersBackground").extends(gfx.sprite)

function GridNumbersBackground:init()
	GridNumbersBackground.super.init(self, gfx.image.new(400, 240))

	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(Z_INDEX_GRID_NUMBERS_BG)
end

function GridNumbersBackground:enter(puzzle)
	self.puzzle = puzzle

	self:add()
	self:redraw()
end

function GridNumbersBackground:leave()
	self:remove()
end

function GridNumbersBackground:redraw()
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		gfx.setDrawOffset(GRID_OFFSET_X + CELL * (15 - self.puzzle.width), GRID_OFFSET_Y)

		-- left lines
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.9)
		for y = 0, self.puzzle.height do
			gfx.drawLine(CELL * -8 + 3, CELL * y, -3, CELL * y)
		end

		-- top lines
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.85)
		for x = 0, self.puzzle.width do
			gfx.drawLine(CELL * x, CELL * -5 + 11, CELL * x, -3)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
