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
		self:drawAvatar(1, 0)
		self:drawAvatar(3, 240-24)
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Sidebar:drawAvatar(id, y)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, y - 2, 24, 28)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, y - 1, 24, 26)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, y, 24, 24)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(1, y + 1, 22, 22)
	imgAvatars:getImage(id):drawScaled(2, y + 2, 2)
end
