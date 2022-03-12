class("GridSolved").extends(gfx.sprite)

function GridSolved:init()
	self.image = gfx.image.new(400 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y)
	GridSolved.super.init(self, self.image)

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
		local width = self.puzzle.width
		local height = self.puzzle.height

		-- border
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, CELL * width + 1, CELL * height + 1)

		-- cells
		local i = 1
		for y = 0, height - 1 do
			for x = 0, width - 1 do
				if self.solution[i] == 1 then
					gfx.fillRect(x * CELL + 1, y * CELL + 1, CELL, CELL)
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
