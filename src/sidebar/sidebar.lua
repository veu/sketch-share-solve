class("Sidebar").extends(gfx.sprite)

function Sidebar:init()
	Sidebar.super.init(self, gfx.image.new(SIDEBAR_WIDTH + 3, 240))

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

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_SIDEBAR)

	self.onAbort = function () end
	self.onNavigated = function () end
	self.onSelected = function () end
end

function Sidebar:enter(context, config, player, creator, same)
	self.config = config
	self.menuItems = config.menuItems
	self.menuTitle = config.menuTitle
	self.stayOpen = config.stayOpen

	self.animator = nil
	self.onLeft = function () end

	self.cursor = 1
	self.cursorRaw = 1
	local menuItems = self.menuItems
	for i = 1, #menuItems do
		if menuItems[i].selected then
			self.cursor = i
			self.cursorRaw = i
			break
		end
	end

	self:add()

	local isOpen <const> = context.isSidebarOpen
	self.isOpen = isOpen
	self:moveTo(isOpen and 0 or -SIDEBAR_WIDTH + 24, 0)
	self.playerAvatar:enter(config, config.player)
	self.playerAvatar:moveTo(isOpen and 0 or -SIDEBAR_WIDTH + 24, Sidebar.playerAvatar.y)
	self.creatorAvatar:enter(config, config.creator)
	self.creatorAvatar:moveTo(isOpen and 0 or -SIDEBAR_WIDTH + 24, Sidebar.creatorAvatar.y)
	self.list:moveTo()
	self.menuBorder:moveTo(isOpen and 0 or -SIDEBAR_WIDTH + 24, 0)
	self.list:enter(context, self.menuItems, self.menuTitle, same)
	self.list:select(self.cursor, true)
	if not context.scrolling then
		self.list.highlightUpdate = true
		self.list.needsRedraw = true
	end
	self:redraw()

	if isOpen then
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
	local max = rawlen(self.menuItems)
	self.cursorRaw = math.max(1, math.min(max, (self.cursorRaw - acceleratedChange / 20)))
	local newCursor = math.floor(self.cursorRaw + 0.5)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
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
		self:onMoved()
	else
		playEffect("scrollEnd")
	end
end

function Sidebar:leftButtonDown()
	local item = self.menuItems[self.cursor]
	if not item.disabled and item.execLeft then
		item.execLeft()
		playEffect("back")
		return
	end
	local newCursor = math.max(1, self.cursor - 6)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.cursorRaw = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:onMoved()
	else
		playEffect("scrollEnd")
	end
end

function Sidebar:rightButtonDown()
	local item = self.menuItems[self.cursor]
	if not item.disabled and item.execRight then
		item.execRight()
		playEffect("click")
		return
	end
	local newCursor = math.min(rawlen(self.menuItems), self.cursor + 6)
	if self.cursor ~= newCursor then
		self.cursor = newCursor
		self.cursorRaw = newCursor
		self.list:select(self.cursor)
		self:onNavigated_(self.menuItems[self.cursor].ref)
		self.onNavigated(self.menuItems[self.cursor].ref)
		self:onMoved()
	else
		playEffect("scrollEnd")
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
		self:onMoved()
	else
		playEffect("scrollEnd")
	end
end

function Sidebar:AButtonDown()
	local item = self.menuItems[self.cursor]
	if item.disabled then
		if item.disabledText then
			showModal(item.disabledText)
		end
		return
	end
	self.list.highlightUpdate = true
	self.list.needsRedraw = true
	playEffect("click")
	if item.exec then
		item.exec()
	else
		self.onSelected(item.ref)
	end
end

function Sidebar:BButtonDown()
	playEffect("back")
	self.onAbort()
end

function Sidebar:buttonPressed(button)
	if button == playdate.kButtonDown then
		self:downButtonDown(true)
	elseif button == playdate.kButtonUp then
		self:upButtonDown(true)
	end
end

function Sidebar:open()
	self.isOpen = true
	local start = self.animator and self.animator:currentValue() or SEPARATOR_WIDTH - SIDEBAR_WIDTH
	self.animator = gfx.animator.new(
		400, start, 0, playdate.easingFunctions.inOutSine
	)
	self:redraw()
end

function Sidebar:close()
	local start = self.animator and self.animator:currentValue() or 0
	self.animator = gfx.animator.new(
		400, start, SEPARATOR_WIDTH - SIDEBAR_WIDTH, playdate.easingFunctions.inOutSine
	)
	self:redraw()
end

function Sidebar:update()
	if self.animator then
		local currentValue = math.floor(self.animator:currentValue() + .5)
		self:moveTo(currentValue, 0)
		self.playerAvatar:moveTo(currentValue, Sidebar.playerAvatar.y)
		self.creatorAvatar:moveTo(currentValue, Sidebar.creatorAvatar.y)
		self.list:moveTo()
		self.menuBorder:moveTo(currentValue, 0)

		if self.animator:ended() then
			self.animator = nil

			if currentValue == SEPARATOR_WIDTH - SIDEBAR_WIDTH then
					self.isOpen = false
			end
		end

		self:redraw()
	end
end

function Sidebar:onCranked()
end

function Sidebar:onMoved()
end

function Sidebar:onNavigated_()
end

function Sidebar:redraw()
	self:setImage(imgSidebar:getImage(self.isOpen and self.x % 4 + 1 or 5))
end
