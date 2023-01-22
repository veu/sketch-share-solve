class("GridSolved").extends(gfx.sprite)

function GridSolved:init()
	self.image = gfx.image.new(400 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y)
	self.imageRotated = gfx.image.new(400 - GRID_OFFSET_X, 240 - GRID_OFFSET_Y)
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
	self:drawRotated()
	self:moveTo(GRID_OFFSET_X + CELL * (15 - puzzle.width), 8)

	self.animator = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
end

function GridSolved:leave()
	self:remove()
	self.animator = nil
	self.animatorRotated = nil
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

function GridSolved:drawRotated()
	self.imageRotated:clear(gfx.kColorWhite)
	gfx.lockFocus(self.imageRotated)
	do
		local width = self.puzzle.width
		local height = self.puzzle.height

		-- background
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(69, 4, 10 * height + 2, 10 * width + 2)

		-- cells
		gfx.setColor(gfx.kColorWhite)
		local i = 1
		for y = 0, height - 1 do
			for x = 0, width - 1 do
				if self.solution[i] == 0 then
					if self.puzzle.rotation == 1 then
						gfx.fillRect(y * 10 + 70, (self.puzzle.width - x - 1) * 10 + 5, 10, 10)
					else
						gfx.fillRect((self.puzzle.height - y - 1) * 10 + 70, x * 10 + 5, 10, 10)
					end
				end
				i += 1
			end
		end
	end
	gfx.unlockFocus()
end

function GridSolved:update()
	if self.animator then
		self:setImage(
			self.image:fadedImage(self.animator:currentValue(), gfx.image.kDitherTypeFloydSteinberg)
		)
		if self.animator:ended() then
			self.animator = nil
			if self.puzzle.rotation then
				self.animatorRotated = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
			end
		end
	end
	if self.animatorRotated then
		gfx.lockFocus(self:getImage())
		do
			self.image:draw(0, 0)
			self.imageRotated:drawFaded(0, 0, self.animatorRotated:currentValue(), gfx.image.kDitherTypeBurkes)
		end
		gfx.unlockFocus()
		if self.animatorRotated:ended() then
			self.animatorRotated = nil
		end
	end
end
