local gfx <const> = playdate.graphics

class("About").extends(gfx.sprite)

function About:init()
	About.super.init(self, gfx.image.new(400, 240))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function About:enter(context)
	self:redraw()
	self:add()
	self:moveTo(context.isSidebarOpen and SIDEBAR_WIDTH - SEPARATOR_WIDTH or 0, 0)
end

function About:leave()
	self:remove()
end

function About:sidebarClosed()
	local start =
		self.animator and self.animator:currentValue() or SIDEBAR_WIDTH - SEPARATOR_WIDTH - 10
	self.animator = gfx.animator.new(400, start, 0, playdate.easingFunctions.inOutSine)
end

function About:sidebarOpened()
	local start = self.animator and self.animator:currentValue() or 0
	self.animator = gfx.animator.new(
		400, start, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 10, playdate.easingFunctions.inOutSine
	)
end

function About:update()
	if self.animator then
		local currentValue = math.floor(self.animator:currentValue() + 0.5)
		self:moveTo(currentValue, 0)
		if self.animator:ended() then
			self.animator = nil
		end
	end
end

function About:redraw()
	gfx.lockFocus(self:getImage())
	do
		imgAbout:draw(0, 0)
		gfx.setDrawOffset(216, 20)
		gfx.setFont(fontText)
		gfx.drawTextInRect("Sketch, Share, Solve", 0, 0, 168, 200, 4)
		gfx.drawTextInRect("Version " .. VERSION, 24, 40, 168, 200, 4)
		gfx.drawTextInRect("Scan the QR code for updates, reporting bugs, and the full source code.", 0, 100, 168, 200, 4)
	end
	gfx.unlockFocus()
	self:markDirty()
end
