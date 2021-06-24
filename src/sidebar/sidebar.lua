local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.list = List()
	self.playerAvatar = Avatar("Player")
	self.creatorAvatar = Avatar("Creator")
	self.menuItems = nil
	self.menuTitle = nil
	self.opened = false
	self.animator = nil

	self.image = gfx.image.new(SIDEBAR_WIDTH + 3, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_SIDEBAR)

	self.onAbort = function () end
	self.onNavigated = function () end
	self.onSelected = function () end
end

function Sidebar:enter(config, player, creator)
	self.config = config
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.stayOpen = config.stayOpen
	self.opened = self.stayOpen or not playdate.isCrankDocked()
	self.cursor = 1
	self.cursorRaw = 1
	self:add()
	self.playerAvatar:enter(config, player)
	self.playerAvatar:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, -1)
	self.creatorAvatar:enter(config, creator)
	self.creatorAvatar:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 240 - 25)
	self:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 0)
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
		400, SEPARATOR_WIDTH - SIDEBAR_WIDTH, 0, playdate.easingFunctions.inOutSine
	)
	self:redraw()
end

function Sidebar:close()
	if self.stayOpen then
		return
	end
	self.animator = gfx.animator.new(
		400, 0, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
	)
end

function Sidebar:update()
	if self.animator then
		local currentValue = math.floor(self.animator:currentValue() + 0.5)
		self:moveTo(currentValue, 0)
		self.playerAvatar:moveTo(currentValue, -1)
		self.creatorAvatar:moveTo(currentValue, 240 - 25)

		if self.animator:ended() then
			self.animator = nil

			if currentValue == SEPARATOR_WIDTH - SIDEBAR_WIDTH then
				self.opened = false
				self:redraw()
			end
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

		local height = 240 - (
			self.creatorAvatar:isVisible() and 48 or (
				self.playerAvatar:isVisible() and 23 or 0
			)
		)

		-- draw sidebar
		drawPaddedRect(
			SIDEBAR_WIDTH - 25,
			self.playerAvatar:isVisible() and 24 or 0,
			26,
			height
		)

		-- menu
		drawStripedRect(-1, 24, SIDEBAR_WIDTH - 23, height)
		self.list:draw()
	end

	gfx.unlockFocus()
	self:markDirty()
end
