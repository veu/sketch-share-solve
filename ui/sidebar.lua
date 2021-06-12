local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init(menuItems)
	Sidebar.super.init(self)
	self.menuItems = menuItems
	self.opened = false
	self.animator = nil
	self.width_ = 25
	self.player = nil
	self.creator = nil

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(30)

self.onNavigated = function () end
self.onSelected = function () end
end

function Sidebar:enter(opened, player, creator)
	self.opened = opened
	self.player = player
	self.creator = creator
	self.width_ = 200
	self.cursor = 1
	self.cursorRaw = 1.5
	self:add()
	self:redraw()
end

function Sidebar:updateData(opened, player, creator)
	self.opened = opened
	self.player = player
	self.creator = creator
	self:redraw()
end

function Sidebar:leave()
	self:remove()
end

function Sidebar:cranked(change, acceleratedChange)
	local max = rawlen(self.menuItems)
	self.cursorRaw = (self.cursorRaw - acceleratedChange / 20 - 1 + max) % max + 1
	self.cursor = math.floor(self.cursorRaw)
	self.onNavigated(self.cursor)
	self:redraw()
end

function Sidebar:AButtonDown()
	self.onSelected(self.cursor)
	if self.menuItems[self.cursor].exec then
		self.menuItems[self.cursor].exec()
	end
end

function Sidebar:open()
	self.opened = true
	self:redraw()
	self.animator = gfx.animator.new(500, 24 - self.width_, 0, playdate.easingFunctions.inOutSine)
end

function Sidebar:close()
	self.opened = false
	self:redraw()
	self.animator = gfx.animator.new(500, 0, 24 - self.width_, playdate.easingFunctions.inOutSine)
end

function Sidebar:update()
	if self.animator then
		if self.animator:ended() then
			self:moveTo(self.opened and 0 or 24 - self.width_, 0)
		else
			self:moveTo(math.floor(self.animator:currentValue()), 0)
		end
	end
end

-- HERE

function Sidebar:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontText)

		-- background
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, self.width_, 240)

		-- shadow
		if self.opened then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.5)
			gfx.fillRect(self.width_, 0, 3, 240)
		end

		-- draw sidebar
		drawPaddedRect(self.width_ - 25, 24, 26, 240 - (self.creator and 48 or 23))

		-- player avatar
		drawRightTextRect(
			-1, -1, self.width_ - 23, 26,
			self.player and "Playing" or "Who is playing?"
		)
		drawAvatar(self.width_ - 25, -1, self.player or 1)

		-- creator avatar
		if self.creator then
			drawRightTextRect(-1, 240 - 25, self.width_ - 23, 26, "Creator")
			drawAvatar(self.width_ - 25, 240 - 25, 4)
		end

		-- menu
		drawStripedRect(-1, 24, self.width_ - 23, 240 - (self.creator and 48 or 23))
		drawMenu(0, 25, self.menuItems, self.cursor)
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -self.width_ + 24, 0)
end
