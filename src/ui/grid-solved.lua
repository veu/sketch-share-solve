class("GridSolved").extends(gfx.sprite)

function GridSolved:init()
	GridSolved.super.init(self)

	self.image = gfx.image.new(1000 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_GRID_SOLVED)
end

function GridSolved:enter(puzzle)
	self.last = 0
	self.puzzle = puzzle

	self.solution = puzzle.grid

	self:add()

	self:draw()
	self:moveTo(GRID_OFFSET_X + CELL * (15 - puzzle.width), 8)

	self.animator = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
end

function GridSolved:leave()
	self:remove()
	self.animator = nil
end

function GridSolved:draw()
	self.image:clear(gfx.kColorWhite)
	gfx.lockFocus(self.image)
	do
		-- border
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, CELL * self.puzzle.width + 1, CELL * self.puzzle.height + 1)

		-- cells
		local i = 1
		for y = 1, self.puzzle.height do
			for x = 1, self.puzzle.width do
				if self.solution[i] == 1 then
					gfx.fillRect((x - 1) * CELL + 1, (y - 1) * CELL + 1, CELL, CELL)
				end
				i += 1
			end
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function GridSolved:update()
	if self.animator then
		self:setImage(
			self.image:fadedImage(self.animator:currentValue(), gfx.image.kDitherTypeFloydSteinberg)
		)
		if self.animator:ended() then
			self.animator = nil
		end
	end
end
