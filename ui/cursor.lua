local gfx <const> = playdate.graphics

class("Cursor").extends(gfx.sprite)

function Cursor:init()
	Cursor.super.init(self)

	self.image = gfx.image.new(CELL - 1, CELL - 1, gfx.kColorWhite)
	self:setImage(self.image)
	self:setImageDrawMode(gfx.kDrawModeXOR)
	self:setCenter(0, 0)
	self:moveTo(CELL * BOARD_OFFSET_X + 1, CELL * BOARD_OFFSET_Y + 1)
	self:setZIndex(20)
	self:add()
end

function Cursor:loadLevel(level)
	self.gridX = 1
	self.gridY = 1
	self.level = level
end

function Cursor:moveBy(dx, dy)
	self.gridX = (self.gridX + dx + self.level.width - 1) % self.level.width + 1
	self.gridY = (self.gridY + dy + self.level.height - 1) % self.level.height + 1
	self:moveTo(CELL * (BOARD_OFFSET_X - 1 + self.gridX) + 1, CELL * (BOARD_OFFSET_Y - 1 + self.gridY) + 1)
	gfx.lockFocus(self.image)
	do
		gfx.clear(gfx.kColorClear)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(
			0, 0,
			CELL - (self.gridX % 5 == 0 and 2 or 1),
			CELL - (self.gridY % 5 == 0 and 2 or 1)
		)
	end
	gfx.unlockFocus()
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * self.level.width + 1
end