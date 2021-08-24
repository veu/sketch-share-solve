class("Cursor").extends(gfx.sprite)

function Cursor:init()
	Cursor.super.init(self)
	self.type = 1

	self.image = gfx.image.new(CELL + 7, CELL + 7, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_CURSOR)

	self:redraw()

	self.onMove = function () end
end

function Cursor:enter(puzzle, mode)
	self.gridX = math.floor(puzzle.width / 2)
	self.gridY = 4
	self.offsetX = mode == MODE_AVATAR
		and GRID_OFFSET_AVATAR_X
		or GRID_OFFSET_X + CELL * (15 - puzzle.width)
	self.offsetY = mode == MODE_AVATAR and GRID_OFFSET_AVATAR_Y or GRID_OFFSET_Y
	self.puzzle = puzzle
	self:move()
	self:add()
	self.onMove(self.gridX, self.gridY)
end

function Cursor:leave()
	self:remove()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * self.puzzle.width + 1
end

function Cursor:startTranslating()
	self.type = 2
	self:redraw()
end

function Cursor:endTranslating()
	self.type = 1
	self:redraw()
end

function Cursor:moveBy(dx, dy, pressed)
	if pressed then
		self.gridX = math.max(1, math.min(self.puzzle.width, self.gridX + dx))
		self.gridY = math.max(1, math.min(self.puzzle.height, self.gridY + dy))
	else
		self.gridX = (self.gridX + dx + self.puzzle.width - 1) % self.puzzle.width + 1
		self.gridY = (self.gridY + dy + self.puzzle.height - 1) % self.puzzle.height + 1
	end
	self:move()
	self.onMove(self.gridX, self.gridY)
end

function Cursor:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		imgCursor:drawImage(self.type, 0, 0)
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Cursor:move()
	self:moveTo(
		self.offsetX + CELL * (self.gridX - 1) - 3,
		self.offsetY + CELL * (self.gridY - 1) - 3
	)
end
