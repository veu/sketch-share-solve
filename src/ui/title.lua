local gfx <const> = playdate.graphics

class("Title").extends(gfx.sprite)

function Title:init()
	Title.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function Title:enter()
	self:redraw()
	self:add()
end

function Title:leave()
	self:remove()
end

function Title:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		imgTitle:draw(0, 0)
	end
	gfx.unlockFocus()
	self:markDirty()
end
