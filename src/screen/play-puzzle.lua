class("PlayPuzzleScreen").extends(Screen)

function PlayPuzzleScreen:init()
	PlayPuzzleScreen.super.init(self)

	self.grid = Grid(true)
	self.timer = Timer()
	self.hintCount = 0

	self.onChanged = function () end
	self.onPlayed = function () end
end

function PlayPuzzleScreen:enter(context)
	self.puzzle = context.puzzle
	self.mode = context.mode
	self.grid.onUpdateSolution = function ()
		if self.puzzle:isSolved(self.grid.solution) then
			self.onPlayed(self.timer.current)
		else
			self.onChanged()
		end
	end

	self.grid:enter(self.puzzle, MODE_PLAY, context.player.options.showHints, context.settings.hintStyle)
	self.timer:enter(context.player.options.showTimer, MODE_PLAY)
	self.cantIdle = context.player.options.showTimer
end

function PlayPuzzleScreen:leave()
	self.grid:leave()
	self.timer:leave()
end

function PlayPuzzleScreen:resetGrid()
	self.timer:reset()
	self.grid:reset()
	self.hintCount = 0
end

function PlayPuzzleScreen:updateHintStyle(context)
	self.grid:updateHintStyle(context.settings.hintStyle)
end

function PlayPuzzleScreen:AButtonDown()
	self:fill(true)
end

function PlayPuzzleScreen:BButtonDown()
	self:cross(true)
end

function PlayPuzzleScreen:cross(isStart)
	self.grid:toggleCross(self.grid:getCursor(), isStart)
end

function PlayPuzzleScreen:fill(isStart)
	self.grid:toggle(self.grid:getCursor(), isStart)
end

function PlayPuzzleScreen:dpadButtonDown(dx, dy, pressed)
	if playdate.buttonIsPressed(playdate.kButtonA) then
		self.grid:moveBy(dx, dy, pressed)
		self:fill(false)
	elseif playdate.buttonIsPressed(playdate.kButtonB) then
		self.grid:moveBy(dx, dy, pressed)
		self:cross(false)
	else
		self.grid:moveBy(dx, dy, false)
	end
end

function PlayPuzzleScreen:downButtonDown(pressed)
		self:dpadButtonDown(0, 1, pressed)
end

function PlayPuzzleScreen:leftButtonDown(pressed)
	self:dpadButtonDown(-1, 0, pressed)
end

function PlayPuzzleScreen:rightButtonDown(pressed)
	self:dpadButtonDown(1, 0, pressed)
end

function PlayPuzzleScreen:upButtonDown(pressed)
	self:dpadButtonDown(0, -1, pressed)
end

function PlayPuzzleScreen:buttonPressed(button)
	if button == playdate.kButtonDown then
		self:downButtonDown(true)
	elseif button == playdate.kButtonLeft then
		self:leftButtonDown(true)
	elseif button == playdate.kButtonRight then
		self:rightButtonDown(true)
	elseif button == playdate.kButtonUp then
		self:upButtonDown(true)
	end
end

function PlayPuzzleScreen:giveHint()
	if self.hintCount > 2 then
		return
	end
	
	local solution = self.grid.solution
	local puzzleGrid = self.grid.puzzle.grid
	local empties = {}
	for index, value in pairs(solution) do
		if value == 0 and puzzleGrid[index] == 0 then
			table.insert(empties, index);
		end
	end
	
	if #empties == 0 then
		return
	end
	
	local cursor = self.grid.cursor
	cursor:moveToIndex(empties[math.random(1, #empties)])
	self.grid:toggleCross(cursor:getIndex(), true)
	self.hintCount += 1;
end

