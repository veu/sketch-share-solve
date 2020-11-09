local gfx <const> = playdate.graphics

local CELL = 16

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

function Numbers:calculate(level)
	self:calcLeft(level)
	self:calcTop(level)
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
	for y = 1, height do
		for i, v in pairs(leftNumbers[y]) do
			gfx.drawText(v, CELL * (i + 5 - rawlen(leftNumbers[y])), CELL * (y + 3) + 1)
		end
		gfx.drawLine(CELL, CELL * (y + 4), CELL * 6, CELL * (y + 4))
	end
end

function Numbers:drawTop()
	for x = 1, width do
		for i, v in pairs(topNumbers[x]) do
			gfx.drawText(v, CELL * (x + 5) + 1, CELL * (i + 3 - rawlen(topNumbers[x])))
		end
		gfx.drawLine(
			CELL * (x + 6), CELL,
			CELL * (x + 6), CELL * 6
		)
	end
end

function Numbers:calcLeft(level)
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

function Numbers:calcTop(level)
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