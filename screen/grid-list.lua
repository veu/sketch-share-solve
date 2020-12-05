local gfx <const> = playdate.graphics

class("GridList").extends(Screen)

function GridList:init()
	GridList.super.init(self)

	self.list = gfx.sprite.new()
	self.list:setImage(gfx.image.new(400, 240, gfx.kColorClear))
	self.list:setCenter(0, 0)
	self.cursor = 1
end

function GridList:enter()
	self.list:add()
end

function GridList:leave()
	self.list:remove()
end

function GridList:update()
	handleCursorDir(fill, cross, playdate.kButtonDown, function ()
		self.cursor = self.cursor % rawlen(LEVELS) + 1
	end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function ()
		self.cursor = (self.cursor - 2) % rawlen(LEVELS) + 1
	end)

	if playdate.buttonJustPressed(playdate.kButtonA) then
		self.onSelectLevel(LEVELS[self.cursor])
		return
	end

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
