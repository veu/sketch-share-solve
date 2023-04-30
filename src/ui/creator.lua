local gfx <const> = playdate.graphics

class("Creator").extends(gfx.sprite)

function Creator:init()
	Creator.super.init(self, imgRdk)

	self:setCenter(1, 1)
	self:setZIndex(Z_INDEX_CREATOR)
end

function Creator:enter()
	self:add()
	self:moveTo(400, 240)
end

function Creator:leave()
	self:remove()
end
