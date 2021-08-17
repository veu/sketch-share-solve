local gfx <const> = playdate.graphics

class("Creator").extends(gfx.sprite)

function Creator:init()
	Creator.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(imgRdk)
	self:setCenter(1, 1)
	self:setZIndex(Z_INDEX_CREATOR)
end

function Creator:enter(context)
	self:add()
	self:moveTo(400, 240)
end

function Creator:leave()
	self:remove()
end
