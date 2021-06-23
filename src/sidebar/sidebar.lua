local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.list = List()
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

function Sidebar:enter(config, opened, player, creator)
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.opened = opened
	self.player = player
	self.creator = creator
	self.cursor = 1
	self.cursorRaw = 1.5
	self:add()
	self.list:enter(self.menuItems, self.menuTitle)
	self:redraw()

	if opened then
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
	end
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
	self.cursorRaw = math.max(1, math.min(max, (self.cursorRaw - acceleratedChange / 20)))
	local newCursor = math.floor(self.cursorRaw)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:redraw()
	end
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
	self.opened = true
	self.animator = gfx.animator.new(
		500, SEPARATOR_WIDTH - SIDEBAR_WIDTH, 0, playdate.easingFunctions.inOutSine
	)
end

function Sidebar:close()
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
		else
			self:moveTo(math.floor(self.animator:currentValue()), 0)
		end
	end
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
			drawAvatar(SIDEBAR_WIDTH - 25, -1, self.player)
		end

		-- creator avatar
		if self.creator then
			drawRightTextRect(-1, 240 - 25, SIDEBAR_WIDTH - 23, 26, "Creator")
			drawAvatar(SIDEBAR_WIDTH - 25, 240 - 25, self.creator)
		end

		-- menu
		drawStripedRect(-1, 24, SIDEBAR_WIDTH - 23, height)
		self.list:draw()
	end
	gfx.unlockFocus()
	self:markDirty()
	self:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 0)
end
