class("GridCreate").extends(Screen)

function GridCreate:init()
	GridCreate.super.init(self)

	self.board = Board()
end

function GridCreate:enter(context)
	self.level = context.level
	self.board:enter(self.level, MODE_CREATE)
	self.board.onUpdateSolution = function (level)
		self.level.level = level
	end

	local sidebarConfig = {
		topText = "Playing",
		menuItems = {
			{
				text = "Test and Save",
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Invert colors",
				exec = function()
					self.board:invert()
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
	self.sidebar.onAbort = function ()
		self.onBackToList()
	end
end

function GridCreate:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.sidebar:leave()
end

function GridCreate:update()
	function cross(isStart)
		self.board:toggleCross(self.board:getCursor(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.board:getCursor(), isStart)
	end

	if self.sidebar.opened then
		return
	end

	handleFill(fill)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.board:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.board:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.board:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.board:moveBy(0, -1) end)
end
