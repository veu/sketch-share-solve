local gfx <const> = playdate.graphics

class("Cursor").extends(gfx.sprite)

function Cursor:init()
	Cursor.super.init(self)

	self.image = gfx.image.new(CELL + 5, CELL + 5, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_CURSOR)

	gfx.pushContext(self.image)
	do
		gfx.clear(gfx.kColorClear)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, CELL + 5, CELL + 5)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRoundRect(1, 1, CELL + 3, CELL + 3, 3)
		gfx.setColor(gfx.kColorClear)
		gfx.fillRoundRect(3, 3, CELL - 1, CELL - 1, 2)
	end
	gfx.popContext()

	self.onMove = function () end
end

function Cursor:enter(puzzle)
	self.gridX = math.floor(puzzle.width / 2)
	self.gridY = 4
	self:moveTo(
		GRID_OFFSET_X + CELL * (15 - puzzle.width) + CELL * (self.gridX - 1) - 2,
		GRID_OFFSET_Y - CELL * (self.gridY - 1) - 2
	)
	self.puzzle = puzzle
	self:redraw()
	self:add()
	self.onMove(self.gridX, self.gridY)
end

function Cursor:leave()
	self:remove()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * self.puzzle.width + 1
end

function Cursor:moveBy(dx, dy, pressed)
	if pressed then
		self.gridX = math.max(1, math.min(self.puzzle.width, self.gridX + dx))
		self.gridY = math.max(1, math.min(self.puzzle.height, self.gridY + dy))
	else
		self.gridX = (self.gridX + dx + self.puzzle.width - 1) % self.puzzle.width + 1
		self.gridY = (self.gridY + dy + self.puzzle.height - 1) % self.puzzle.height + 1
	end
	self:redraw()
	self.onMove(self.gridX, self.gridY)
end

function Cursor:redraw()
	self:moveTo(
		GRID_OFFSET_X + CELL * (15 - self.puzzle.width) + CELL * (self.gridX - 1) - 2,
		GRID_OFFSET_Y + CELL * (self.gridY - 1) - 2
	)
end
