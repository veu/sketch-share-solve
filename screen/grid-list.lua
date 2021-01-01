local gfx <const> = playdate.graphics

class("GridList").extends(Screen)

function GridList:init()
	GridList.super.init(self)

	self.list = gfx.sprite.new()
	self.list:setImage(gfx.image.new(400, 240, gfx.kColorClear))
	self.list:setCenter(0, 0)
	self.cursor = 1
	self.cursorRaw = 1.5
end

function GridList:enter()
	self.list:add()
	self:redraw()
end

function GridList:leave()
	self.list:remove()
end

function GridList:cranked(change, acceleratedChange)
	local max = rawlen(LEVELS)
	self.cursorRaw = (self.cursorRaw - acceleratedChange / 20 - 1 + max) % max + 1
	self.cursor = math.floor(self.cursorRaw)
	self:redraw()
end

function GridList:AButtonDown()
	self.onSelectLevel(LEVELS[self.cursor])
end

function GridList:redraw()
	gfx.lockFocus(self.list:getImage())
	do
		gfx.clear()

		for i, level in pairs(LEVELS) do
			gfx.drawText("*Level " .. i .. "*", 10, 24 * i - 14)
		end

		gfx.drawRect(4, 24 * self.cursor - 4 - 14, 80, 24)
	end
	gfx.unlockFocus()
	self.list:markDirty()
end
