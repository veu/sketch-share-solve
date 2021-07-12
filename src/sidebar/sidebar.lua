local gfx <const> = playdate.graphics

class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self)
	self.list = List(self)
	self.menuBorder = MenuBorder()
	if not Sidebar.playerAvatar then
		Sidebar.playerAvatar = PlayerAvatar()
	end
	if not Sidebar.creatorAvatar then
		Sidebar.creatorAvatar = CreatorAvatar()
	end
	self.menuItems = nil
	self.menuTitle = nil
	self.opened = false

	self.image = gfx.image.new(SIDEBAR_WIDTH + 3, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_SIDEBAR)

	self.onAbort = function () end
	self.onNavigated = function () end
	self.onSelected = function () end
end

function Sidebar:enter(context, config, player, creator)
	self.config = config
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.stayOpen = config.stayOpen
	self.opened = self.stayOpen or not context.isCrankDocked

	self.animator = nil
	self.onLeft = function () end

	self.cursor = 1
	self.cursorRaw = 1
	for i, item in pairs(self.menuItems) do
		if item.selected then
			self.cursor = i
			self.cursorRaw = i
		end
	end

	self:add()
	self:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 0)
	self.playerAvatar:enter(config, config.player)
	self.playerAvatar:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, Sidebar.playerAvatar.y)
	self.creatorAvatar:enter(config, config.creator)
	self.creatorAvatar:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, Sidebar.creatorAvatar.y)
	self.list:moveTo()
	self.menuBorder:moveTo(self.opened and 0 or -SIDEBAR_WIDTH + 24, 0)
	self.list:enter(context, self.menuItems, self.menuTitle)
	self.list:select(self.cursor)
	self:redraw()

	if opened then
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
	end
end

function Sidebar:leave(context)
	self.menuBorder:enter()
	self.list.onLeft = function ()
		self.menuBorder:leave()
		self:onLeft_()
	end
	self.list:leave(context)
end

function Sidebar:onLeft_()
	self.playerAvatar:leave()
	self:remove()
	self.onLeft()
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

function Sidebar:downButtonDown()
	local newCursor = math.min(rawlen(self.menuItems), self.cursor + 1)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.cursorRaw = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:redraw()
		self:onMoved()
	end
end

function Sidebar:leftButtonDown()
	local item = self.menuItems[self.cursor]
	if not item.disabled and item.execLeft then
		item.execLeft()
	end
end

function Sidebar:rightButtonDown()
	local item = self.menuItems[self.cursor]
	if not item.disabled and item.execRight then
		item.execRight()
	end
end

function Sidebar:upButtonDown()
	local newCursor = math.max(1, self.cursor - 1)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.cursorRaw = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:redraw()
		self:onMoved()
	end
end

function Sidebar:AButtonDown()
	local item = self.menuItems[self.cursor]
	if item.disabled then
		return
	end
	if item.exec then
		item.exec()
	else
		self.onSelected(item.ref)
	end
end

function Sidebar:BButtonDown()
	self.onAbort()
end

function Sidebar:open()
	if self.stayOpen then
		return
	end
	self.opened = true
	local start = self.animator and self.animator:currentValue() or SEPARATOR_WIDTH - SIDEBAR_WIDTH
	self.animator = gfx.animator.new(
		400, start, 0, playdate.easingFunctions.inOutSine
	)
	self:redraw()
end

function Sidebar:close()
	if self.stayOpen then
		self.onAbort()
	end
	local start = self.animator and self.animator:currentValue() or 0
	self.animator = gfx.animator.new(
		400, start, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
	)
end

function Sidebar:update()
	if self.animator then
		local currentValue = self.animator:currentValue()
		self:moveTo(currentValue, 0)
		self.playerAvatar:moveTo(currentValue, -1)
		self.creatorAvatar:moveTo(currentValue, Sidebar.creatorAvatar.y)
		self.list:moveTo()
		self.menuBorder:moveTo(currentValue, 0)

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

function Sidebar:onMoved()
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

		local height = 242

		-- draw sidebar
		drawPaddedRect(SIDEBAR_WIDTH - 25, -1, 26, 242)

		-- menu
		drawStripedRect(-1, -1, SIDEBAR_WIDTH - 23, height)
	end

	gfx.unlockFocus()
	self:markDirty()
end
