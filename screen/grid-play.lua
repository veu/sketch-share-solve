class("GridPlay").extends(Screen)

function GridPlay:init()
	GridPlay.super.init(self)

	self.board = Board()
	self.numbers = BoardNumbers()
end

function GridPlay:enter(context)
	self.level = context.level
	self.mode = context.mode
	self.board:enter(self.level, MODE_PLAY)
	self.board.onUpdateSolution = function (solution)
		if self.level:isSolved(solution) then
			self.board:hideCursor()
		end
	end
	self.numbers:enter(Numbers(self.level))

	local sidebarConfig = {
		topText = "Playing",
		menuItems = {}
	}

	if self.mode == MODE_CREATE then
		table.insert(sidebarConfig.menuItems, {
			text = "Save",
			exec = function()
				self.onSave()
			end
		})
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

	self.sidebar.onAbort = function ()
		if self.mode == MODE_CREATE then
			self.onEdit()
		else
			self.onBackToList()
		end
	end
end

function GridPlay:leave()
	local menu = playdate.getSystemMenu()
	menu:removeAllMenuItems()

	self.board:leave()
	self.numbers:leave()
	self.sidebar:leave()
end

function GridPlay:update()
	function cross(isStart)
		self.board:toggleCross(self.board:getCursor(), isStart)
	end

	function fill(isStart)
		self.board:toggle(self.board:getCursor(), isStart)
	end

	if self.sidebar.opened or self.level:isSolved(self.board.solution) then
		return
	end

	handleFill(fill)
	handleCross(cross)
	handleCursorDir(fill, cross, playdate.kButtonRight, function () self.board:moveBy(1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonDown, function () self.board:moveBy(0, 1) end)
	handleCursorDir(fill, cross, playdate.kButtonLeft, function () self.board:moveBy(-1, 0) end)
	handleCursorDir(fill, cross, playdate.kButtonUp, function () self.board:moveBy(0, -1) end)
end
