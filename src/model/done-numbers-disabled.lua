class("DoneNumbersDisabled").extends()

function DoneNumbersDisabled:init(puzzle)
	self.left = table.create(puzzle.height, 0)
	for y = 1, puzzle.height do
		self.left[y] = {}
	end
	self.top = table.create(puzzle.width, 0)
	for x = 1, puzzle.width do
		self.top[x] = {}
	end
end

function DoneNumbersDisabled:updatePosition()
end

function DoneNumbersDisabled:updateAll()
end
