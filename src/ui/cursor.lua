class("Cursor").extends(gfx.sprite)

local CURSOR_DRAW = 1
local CURSOR_MOVE = 2

function Cursor:init()
	Cursor.super.init(self, imgCursor:getImage(CURSOR_DRAW))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_CURSOR)

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
	self:add()
	self:move()
end

function Cursor:leave()
	self:remove()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * self.puzzle.width + 1
end

function Cursor:startTranslating()
	self:setImage(imgCursor:getImage(CURSOR_MOVE))
end

function Cursor:endTranslating()
	self:setImage(imgCursor:getImage(CURSOR_DRAW))
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
end

function Cursor:move()
	self:moveTo(
		self.offsetX + CELL * (self.gridX - 1) - 3,
		self.offsetY + CELL * (self.gridY - 1) - 3
	)
	self.onMove(self.gridX, self.gridY)
end
