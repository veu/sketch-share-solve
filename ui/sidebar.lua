local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.list = List()
	self.menuItems = nil
	self.menuTitle = nil
	self.opened = false
	self.animator = nil
	self.width_ = 25
	self.player = nil
	self.creator = nil

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(30)

	self.onAbort = function () end
	self.onNavigated = function () end
	self.onSelected = function () end
end

function Sidebar:enter(config, opened, player, creator)
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.opened = opened
	self.player = player
	self.creator = creator
	self.width_ = 200
	self.cursor = 1
	self.cursorRaw = 1.5
	self:add()
	self.list:enter(self.menuItems, self.menuTitle)
	self:redraw()
end

function Sidebar:setPlayer(player)
	self.player = player
	self:redraw()
end

function Sidebar:setCreator(creator)
	self.creator = creator
	self:redraw()
end

function Sidebar:leave()
	self:remove()
end

function Sidebar:cranked(change, acceleratedChange)
	if not self.opened then
		return
	end
	local max = rawlen(self.menuItems)
	self.cursorRaw = (self.cursorRaw - acceleratedChange / 20 - 1 + max) % max + 1
	self.cursor = math.floor(self.cursorRaw)
	self.list:select(self.cursor)
	self.onNavigated(self.menuItems[self.cursor].ref)
	self:redraw()
end

function Sidebar:AButtonDown()
	if not self.opened then
		return
	end
	self.onSelected(self.menuItems[self.cursor].ref)
	if self.menuItems[self.cursor].exec then
		self.menuItems[self.cursor].exec()
	end
end

function Sidebar:BButtonDown()
	if not self.opened then
		return
	end
	self.onAbort()
end

function Sidebar:open()
	self.opened = true
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
	if self.opened then
		self:redraw()
	end
end

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

		local height = 240 - (self.creator and 48 or (self.player and 23 or 0))

		-- draw sidebar
		drawPaddedRect(self.width_ - 25, self.player and 24 or 0, 26, height)

		-- player avatar
		if self.player then
			drawRightTextRect(-1, -1, self.width_ - 23, 26, "Playing")
			drawAvatar(self.width_ - 25, -1, self.player or 1)
		end

		-- creator avatar
		if self.creator then
			drawRightTextRect(-1, 240 - 25, self.width_ - 23, 26, "Creator")
			drawAvatar(self.width_ - 25, 240 - 25, self.creator)
		end

		-- menu
		drawStripedRect(-1, 24, self.width_ - 23, height)
		self.list:draw()
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -self.width_ + 24, 0)
end
