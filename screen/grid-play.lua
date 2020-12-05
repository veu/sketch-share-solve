class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.cursor = Cursor()
	self.numbers = Numbers()
	self.sidebar = Sidebar()
end

function GridPlay:enter(level)
	local menu = playdate.getSystemMenu()
	local menuItem, error = menu:addMenuItem("restart grid", function()
		self.board:loadLevel(self.level)
	end)
	assert(menuItem, error)
	local menuItem, error = menu:addMenuItem("grid overview", function()
		self.onBackToList()
	end)
	assert(menuItem, error)

	self.level = Level(level)
	self.board:enter(self.level)
	self.cursor:enter(self.level)
	self.numbers:enter(self.level)
	self.sidebar:enter(self.level)
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

function GridPlay:update()
	function cross(isStart)
		self.board:toggleCross(self.cursor:getIndex(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.cursor:getIndex(), isStart)
	end

	if self.level:isSolved(self.board.solution) then
		return
	end
	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.cursor:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.cursor:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.cursor:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.cursor:moveBy(0, -1) end)
end
