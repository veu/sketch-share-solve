local gfx <const> = playdate.graphics

class("Numbers").extends(gfx.sprite)

function Numbers:init()
	Numbers.super.init(self)

	self.image = gfx.image.new(400, 240, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:moveTo(0, 0)
	self:setZIndex(7)
	self:add()
end

function Numbers:loadLevel(level, width, height)
	self:calcLeft(level, width, height)
	self:calcTop(level, width, height)
end

function Numbers:redraw()
	gfx.lockFocus(self.image)
	self:drawLeft()
	self:drawTop()
	self:markDirty()
	gfx.unlockFocus()
end

local leftNumbers = {}
local topNumbers = {}

function Numbers:drawLeft()
	for y, numbers in pairs(leftNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(v, CELL * (i + 5 - rawlen(numbers)), CELL * (y + 3) + 1)
		end
		gfx.drawLine(CELL, CELL * (y + 4), CELL * 6, CELL * (y + 4))
	end
end

function Numbers:drawTop()
	for x, numbers in pairs(topNumbers) do
		for i, v in pairs(numbers) do
			gfx.drawText(v, CELL * (x + 5) + 1, CELL * (i + 3 - rawlen(numbers)))
		end
		gfx.drawLine(
			CELL * (x + 6), CELL,
			CELL * (x + 6), CELL * 4
		)
	end
end

function Numbers:calcLeft(level, width, height)
	for y = 1, height do
		leftNumbers[y] = {}
		local i = 1
		for x = 1, width do
			local index = x - 1 + (y - 1) * width + 1
			if level[index] == 1 then
				if not leftNumbers[y][i] then
					leftNumbers[y][i] = 1
				else
					leftNumbers[y][i] += 1
				end
			elseif leftNumbers[y][i] then
				i += 1
			end
		end
	end
end

function Numbers:calcTop(level, width, height)
	for x = 1, width do
		topNumbers[x] = {}
		local i = 1
		local numbers = {}
		for y = 1, height do
			local index = x - 1 + (y - 1) * width + 1
			if level[index] == 1 then
				if not topNumbers[x][i] then
					topNumbers[x][i] = 1
				else
					topNumbers[x][i] += 1
				end
			elseif topNumbers[x][i] then
				i += 1
			end
		end
	end
end