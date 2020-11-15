class("GridPlay").extends()

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.cursor = Cursor()
	self.numbers = Numbers()
	self.sidebar = Sidebar()
end

function GridPlay:enter()
	local menu = playdate.getSystemMenu()
	local menuItem, error = menu:addMenuItem("restart grid", function()
		self.board:loadLevel(self.level)
	end)
	assert(menuItem, error)
	local menuItem, error = menu:addMenuItem("grid overview", function()
		print("TODO")
	end)
	assert(menuItem, error)

	self.level = Level(LEVELS[2], 15, 10)
	self.board:loadLevel(self.level)
	self.cursor:loadLevel(self.level)
	self.numbers:loadLevel(self.level)
end

function GridPlay:leave()
end

function GridPlay:update()
	function cross(isStart)
		self.board:toggleCross(self.cursor:getIndex(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.cursor:getIndex(), isStart)
	end

	if not self.level:isSolved(self.board.solution) then
		handleFill(fill)
		handleCross(cross)
		handleCursorDir(fill, cross, playdate.kButtonRight, function () self.cursor:moveBy(1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonDown, function () self.cursor:moveBy(0, 1) end)
		handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.cursor:moveBy(-1, 0) end)
		handleCursorDir(fill, cross, playdate.kButtonUp, function () self.cursor:moveBy(0, -1) end)

		utils.ifChanged(self.sidebar, self.sidebar.update, {
			open = not playdate.isCrankDocked()
		})
	end
end