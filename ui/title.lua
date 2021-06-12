local gfx <const> = playdate.graphics

class("Title").extends(gfx.sprite)

function Title:init()
	Title.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(5)
end

function Title:enter(opened)
	self.sidebarOpened = opened
	self:redraw()
	self:add()
end

function Title:leave()
	self:remove()
end

function Title:setSidebarOpened(opened)
	self.sidebarOpened = opened
	self:redraw()
end

function Title:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		if not self.sidebarOpened then
			gfx.setColor(gfx.kColorBlack)
			local width = gfx.getTextSize("Get cranking")
			gfx.drawText("Get cranking", 400 - width - 20, 20)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
