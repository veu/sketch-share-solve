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
end

function Cursor:enter(level)
	self.gridX = math.floor(level.width / 2)
	self.gridY = 4
	self:moveTo(
		CELL * (BOARD_OFFSET_X - 1 + self.gridX) - 2,
		CELL * (BOARD_OFFSET_Y - 1 + self.gridY) - 2
	)
	self.level = level
	self:redraw()
	self:add()
end

function Cursor:leave()
	self:remove()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * self.level.width + 1
end

function Cursor:moveBy(dx, dy)
	self.gridX = (self.gridX + dx + self.level.width - 1) % self.level.width + 1
	self.gridY = (self.gridY + dy + self.level.height - 1) % self.level.height + 1
	self:redraw()
end

function Cursor:redraw()
	self:moveTo(
		CELL * (BOARD_OFFSET_X - 1 + self.gridX) - 2,
		CELL * (BOARD_OFFSET_Y - 1 + self.gridY) - 2
	)
end
