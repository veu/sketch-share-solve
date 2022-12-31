class("SolvedPuzzleScreen").extends(Screen)

function SolvedPuzzleScreen:init()
	SolvedPuzzleScreen.super.init(self)

	self.grid = Grid()
	self.gridSolved = GridSolved()
	self.dialog = Dialog()
	self.time = Time()
end

function SolvedPuzzleScreen:enter(context)
	self.puzzle = context.puzzle
	self.mode = context.mode

	self.grid:enter(self.puzzle, MODE_CREATE)
	self.grid:hideCursor()
	self.gridAnimator = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
	self.time:enter(context)
end

function SolvedPuzzleScreen:leave()
	self.grid:leave()
	self.gridSolved:leave()
	self.gridAnimator = nil
	self.dialog:leave()
	self.time:leave()
end

function SolvedPuzzleScreen:update()
	if self.gridAnimator then
		self.grid:moveTowardsTop(self.gridAnimator:currentValue())

		if self.gridAnimator:ended() then
			self.gridSolved:enter(self.puzzle)
			self.gridAnimator = nil

			if self.mode == MODE_CREATE then
				self.dialog:enter("You solved it! Ready to save.")
			else
				local title = self.puzzle.title
				self.dialog:enter(title and "You solved \"" .. title .. "\". Well done!" or "You solved it!")
			end
		end
	end
end
