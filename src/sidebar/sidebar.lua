local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.list = List()
	self.playerAvatar = Avatar()
	self.creatorAvatar = Avatar()
	self.menuItems = nil
	self.menuTitle = nil
	self.opened = false
	self.animator = nil
	self.player = nil
	self.creator = nil

	self.image = gfx.image.new(SIDEBAR_WIDTH + 3, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_SIDEBAR)

	self.onAbort = function () end
	self.onNavigated = function () end
	self.onSelected = function () end
end

function Sidebar:enter(config, player, creator)
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.stayOpen = config.stayOpen
	self.opened = self.stayOpen or not playdate.isCrankDocked()
	self.player = player
	self.creator = creator
	self.cursor = 1
	self.cursorRaw = 1
	self:add()
	self.playerAvatar:enter(config, player)
	self.playerAvatar:moveTo(self.opened and AVATAR_OFFSET or -1, -1)
	self.creatorAvatar:enter(config, creator)
	self.creatorAvatar:moveTo(self.opened and AVATAR_OFFSET or -1, 240 - 25)
	self.list:enter(self.menuItems, self.menuTitle)
	self:redraw()

	if opened then
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
	end
end

function Sidebar:leave()
	self.playerAvatar:leave()
	self.creatorAvatar:leave()
	self:remove()
end

function Sidebar:cranked(change, acceleratedChange)
	if not self.opened then
		return
	end
	local max = rawlen(self.menuItems)
	self.cursorRaw = math.max(1, math.min(max, (self.cursorRaw - acceleratedChange / 20)))
	local newCursor = math.floor(self.cursorRaw + 0.5)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:redraw()
	end
	self:onCranked()
end

function Sidebar:AButtonDown()
	if not self.opened or self.menuItems[self.cursor].disabled then
		return
	end
	if self.menuItems[self.cursor].exec then
		self.menuItems[self.cursor].exec()
	else
		self.onSelected(self.menuItems[self.cursor].ref)
	end
end

function Sidebar:BButtonDown()
	if not self.opened then
		return
	end
	self.onAbort()
end

function Sidebar:open()
	if self.stayOpen then
		return
	end
	self.opened = true
	self.animator = gfx.animator.new(
		500, SEPARATOR_WIDTH - SIDEBAR_WIDTH, 0, playdate.easingFunctions.inOutSine
	)
end

function Sidebar:close()
	if self.stayOpen then
		return
	end
	self.opened = false
	self:redraw()
	self.animator = gfx.animator.new(
		500, 0, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
	)
end

function Sidebar:update()
	if self.animator then
		if self.animator:ended() then
			self:moveTo(self.opened and 0 or SEPARATOR_WIDTH - SIDEBAR_WIDTH, 0)
			self.playerAvatar:moveTo(self.opened and AVATAR_OFFSET or -1, -1)
			self.creatorAvatar:moveTo(self.opened and AVATAR_OFFSET or -1, 240 - 25)
		else
			self:moveTo(math.floor(self.animator:currentValue()), 0)
			self.playerAvatar:moveTo(AVATAR_OFFSET + math.floor(self.animator:currentValue()), -1)
			self.creatorAvatar:moveTo(AVATAR_OFFSET + math.floor(self.animator:currentValue()), 240 - 25)
		end
	end
end

function Sidebar:onCranked()
end

function Sidebar:onNavigated_()
end

function Sidebar:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontText)

		-- background
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, SIDEBAR_WIDTH, 240)

		-- shadow
		if self.opened then
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.5)
			gfx.fillRect(SIDEBAR_WIDTH, 0, 3, 240)
		end

		local height = 240 - (self.creator and 48 or (self.player and 23 or 0))

		-- draw sidebar
		drawPaddedRect(SIDEBAR_WIDTH - 25, self.player and 24 or 0, 26, height)

		-- player avatar
		if self.player then
			drawRightTextRect(-1, -1, SIDEBAR_WIDTH - 23, 26, "Player")
		end

		-- creator avatar
		if self.creator then
			drawRightTextRect(-1, 240 - 25, SIDEBAR_WIDTH - 23, 26, "Creator")
		end

		-- menu
		drawStripedRect(-1, 24, SIDEBAR_WIDTH - 23, height)
		self.list:draw()
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 0)
end
