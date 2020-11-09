local gfx <const> = playdate.graphics

local CELL = 16

class("Cursor").extends(gfx.sprite)

function Cursor:init()
	Cursor.super.init(self)

	self.gridX = 1
	self.gridY = 1

	self.image = gfx.image.new(CELL, CELL, gfx.kColorWhite)
	self:setImage(self.image)
	self:setImageDrawMode(gfx.kDrawModeXOR)
	self:setCenter(0, 0)
	self:moveTo(CELL * 6, CELL * 4)
	self:setZIndex(20)
	self:add()
end

function Cursor:moveBy(dx, dy)
	self.gridX = (self.gridX + dx + width - 1) % width + 1
	self.gridY = (self.gridY + dy + height - 1) % height + 1
	self:moveTo(CELL * (5 + self.gridX), CELL * (3 + self.gridY))
end

function Cursor:move(deps)
	self:moveTo(CELL * (5 + deps.x), CELL * (3 + deps.y))
end

function Cursor:getIndex()
	return self.gridX - 1 + (self.gridY - 1) * width + 1
end