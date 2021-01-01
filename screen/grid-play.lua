class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.cursor = Cursor()
	self.numbers = Numbers()

	local menuItems = {
		{
			text = "Reset Grid",
			exec = function()
				self.board:enter(self.level)
			end
		},
		{
			text = "Back to Overview",
			exec = function()
				self.onBackToList()
			end
		}
	}

	self.sidebar = Sidebar(menuItems)

	self.sidebar.fun = function()
		print("reset grid", self.board.enter, self.level)
		self.board:enter(self.level)
		print("reseted grid")
	end
end

function GridPlay:enter(level)
	self.level = Level(level)
	self.board:enter(self.level)
	self.cursor:enter(self.level)
	self.numbers:enter(self.level)
	self.sidebar:enter(self.level, not playdate.isCrankDocked())
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
