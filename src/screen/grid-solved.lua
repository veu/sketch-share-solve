local gfx <const> = playdate.graphics

class("GridSolved").extends(Screen)

function GridSolved:init()
	GridSolved.super.init(self)

	self.board = Board()
	self.dialog = Dialog()
end

function GridSolved:enter(context)
	self.level = context.level

	self.board:enter(self.level, MODE_CREATE)
	self.board:hideCursor()
	self.boardAnimator = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
end

function GridSolved:leave()
	self.board:leave()
	self.dialog:leave()
end

function GridSolved:update()
	if self.boardAnimator then
		self.board:moveTowardsTop(self.boardAnimator:currentValue())

		if self.boardAnimator:ended() then
			self.boardAnimator = nil

			playdate.timer.performAfterDelay(800, function ()
				self.showCrank = true
			end)
			if self.mode == MODE_CREATE then
				self.dialog:enter("You solved it! Ready to save.")
			else
				local title = self.level.title
				self.dialog:enter(title and "You solved \"" .. title .. "\"." or "You solved it!")
			end
		end
	end
end
