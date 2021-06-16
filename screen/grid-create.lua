class("GridCreate").extends(Screen)

function GridCreate:init()
	GridCreate.super.init(self)

	self.board = Board()
	self.cursor = Cursor()
	self.sidebar = Sidebar()
end

function GridCreate:enter(context)
	self.level = context.level
	self.board:enter(self.level, MODE_CREATE)
	self.board.onUpdateSolution = function (level)
		self.level.level = level
	end
	self.cursor:enter(self.level)

	local sidebarConfig = {
		topText = "Playing",
		menuItems = {
			{
				text = "Reset Grid",
				exec = function()
					self.board:enter(self.level)
				end
			},
			{
				text = "Test and Save",
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Back to Title",
				exec = function()
					self.onBackToList()
				end
			}
		}
	}
	self.sidebar:enter(sidebarConfig, not playdate.isCrankDocked(), context.player)
end

function GridCreate:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.cursor:leave()
	self.sidebar:leave()
end

function GridCreate:crankDocked()
	self.sidebar:close()
end

function GridCreate:crankUndocked()
	self.sidebar:open()
end

function GridCreate:cranked(change, acceleratedChange)
	self.sidebar:cranked(change, acceleratedChange)
end

function GridCreate:AButtonDown()
	if self.sidebar.opened then
		self.sidebar:AButtonDown()
	end
end

function GridCreate:BButtonDown()
	self.onBackToList()
end

function GridCreate:update()
	function cross(isStart)
		self.board:toggleCross(self.cursor:getIndex(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.cursor:getIndex(), isStart)
	end

	if self.sidebar.opened then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.cursor:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.cursor:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.cursor:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.cursor:moveBy(0, -1) end)
end
