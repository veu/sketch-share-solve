class("DoneNumbersDisabled").extends()

function DoneNumbersDisabled:init(puzzle)
	self.left = {}
	for y = 1, puzzle.height do
		self.left[y] = {}
	end
	self.top = {}
	for x = 1, puzzle.width do
		self.top[x] = {}
	end
end

function DoneNumbersDisabled:updatePosition()
end
