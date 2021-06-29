class("DoneNumbersDisabled").extends()

function DoneNumbersDisabled:init(level)
	self.left = {}
	for y = 1, level.height do
		self.left[y] = {}
	end
	self.top = {}
	for x = 1, level.width do
		self.top[x] = {}
	end
end

function DoneNumbersDisabled:updatePosition()
end
