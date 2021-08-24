class("Title").extends(gfx.sprite)

function Title:init()
	Title.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function Title:enter(context)
	self:redraw()
	self:add()
	self:moveTo(context.isSidebarOpen and SIDEBAR_WIDTH - SEPARATOR_WIDTH - 10 or 0, 0)
end

function Title:leave()
	self:remove()
end

function Title:sidebarClosed()
	local start =
		self.animator and self.animator:currentValue() or SIDEBAR_WIDTH - SEPARATOR_WIDTH - 10
	self.animator = gfx.animator.new(400, start, 0, playdate.easingFunctions.inOutSine)
end

function Title:sidebarOpened()
	local start = self.animator and self.animator:currentValue() or 0
	self.animator = gfx.animator.new(
		400, start, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 10, playdate.easingFunctions.inOutSine
	)
end

function Title:update()
	if self.animator then
		local currentValue = math.floor(self.animator:currentValue() + 0.5)
		self:moveTo(currentValue, 0)
		if self.animator:ended() then
			self.animator = nil
		end
	end
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
