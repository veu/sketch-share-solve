class("Frame").extends(gfx.sprite)

function Frame:init()
	Frame.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_FRAME)

	gfx.lockFocus(self.image)
	do
		gfx.setColor(gfx.kColorBlack)
		playdate.graphics.setLineWidth(2)
		gfx.drawRect(GRID_OFFSET_AVATAR_X - 9, GRID_OFFSET_AVATAR_Y - 9, CELL * 10 + 19, CELL * 10 + 19)
	end
	gfx.unlockFocus()
end

function Frame:enter()
	self:add()
end

function Frame:leave()
	self:remove()
end
