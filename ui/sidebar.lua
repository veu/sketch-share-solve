local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(30)
	self:add()

	gfx.lockFocus(self.image)
	do
		gfx.setDitherPattern(0.5)
		gfx.fillRect(1, 26, 22, 213)
		gfx.setDitherPattern(0)
		gfx.drawLine(CELL * 1.5, 0, CELL * 1.5, 240)
		gfx.fillRect(1, 1, 22, 22)
		imgAvatars:getImage(1):drawScaled(2, 2, 2)
		gfx.drawLine(0, 24, 24, 24)
	end
	gfx.unlockFocus()
	self:markDirty()
end