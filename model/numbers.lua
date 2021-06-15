class("Numbers").extends()

function Numbers:init(level)
	self.topNumbers = self:calcTopNumbers(level)
	self.leftNumbers = self:calcLeftNumbers(level)
end

function Numbers:calcTopNumbers(level)
	local topNumbers = {}
	for x = 1, level.width do
		topNumbers[x] = {}
		local i = 1
		local numbers = {}
		for y = 1, level.height do
			local index = x - 1 + (y - 1) * level.width + 1
			if level.level[index] == 1 then
				if not topNumbers[x][i] then
					topNumbers[x][i] = 1
				else
					topNumbers[x][i] += 1
				end
			elseif topNumbers[x][i] then
				i += 1
			end
		end
		if rawlen(topNumbers[x]) == 0 then
			topNumbers[x][1] = 0
		end
	end
	return topNumbers
end

function Numbers:calcLeftNumbers(level)
local leftNumbers = {}
for y = 1, level.height do
	leftNumbers[y] = {}
	local i = 1
	for x = 1, level.width do
		local index = x - 1 + (y - 1) * level.width + 1
		if level.level[index] == 1 then
			if not leftNumbers[y][i] then
				leftNumbers[y][i] = 1
			else
				leftNumbers[y][i] += 1
			end
		elseif leftNumbers[y][i] then
			i += 1
		end
	end
	if rawlen(leftNumbers[y]) == 0 then
		leftNumbers[y][1] = 0
	end
end
return leftNumbers
end
