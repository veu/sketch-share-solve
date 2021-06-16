class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.cursor = Cursor()
	self.numbers = BoardNumbers()
	self.sidebar = Sidebar()
end

function GridPlay:enter(context)
	self.level = context.level
	self.mode = context.mode
	self.board:enter(self.level, MODE_PLAY)
	self.cursor:enter(self.level)
	self.numbers:enter(Numbers(self.level))

	local sidebarConfig = {
		topText = "Playing",
		menuItems = {}
	}

	table.insert(sidebarConfig.menuItems, {
		text = "Reset Grid",
		exec = function()
			self.board:enter(self.level)
		end
	})
		table.insert(sidebarConfig.menuItems, {
			text = "Save",
			exec = function()
				self.onSave()
			end
		})
		if self.mode == MODE_CREATE then
			table.insert(sidebarConfig.menuItems, {
				text = "Back to Editor",
				exec = function()
					self.onEdit()
				end
			})
	else
		table.insert(sidebarConfig.menuItems, {
			text = "Back to Overview",
			exec = function()
				self.onBackToList()
			end
		})
	end

	self.sidebar:enter(
		sidebarConfig,
		not playdate.isCrankDocked(),
		context.player,
		context.creator
	)
end

function GridPlay:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.cursor:leave()
	self.numbers:leave()
	self.sidebar:leave()
end

function GridPlay:crankDocked()
	self.sidebar:close()
end

function GridPlay:crankUndocked()
	self.sidebar:open()
end

function GridPlay:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function GridPlay:AButtonDown()
	if self.sidebar.opened then
		self.sidebar:AButtonDown()
	end
end

function GridPlay:BButtonDown()
	if self.mode == MODE_CREATE then
		self.onEdit()
	else
		self.onBackToList()
	end
end

function GridPlay:update()
	function cross(isStart)
		self.board:toggleCross(self.cursor:getIndex(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.cursor:getIndex(), isStart)
	end

	if self.sidebar.opened or self.level:isSolved(self.board.solution) then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.cursor:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.cursor:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.cursor:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.cursor:moveBy(0, -1) end)
end
