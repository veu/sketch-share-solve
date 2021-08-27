class("Time").extends(gfx.sprite)

function Time:init()
	Time.super.init(self)

	self.image = gfx.image.new(127, 92, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TIMER)
	self:moveTo(25, 0)
end

function Time:enter(context)
	self.context = context
	self:redraw()
	self:add()

	self.animator = gfx.animator.new(400, 0, 1, playdate.easingFunctions.inOutSine)
end

function Time:leave()
	self:remove()
end

function Time:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		local lastTime = self.context.player.lastTime
		if self.context.player.options.showTimer and lastTime then
			imgMode:drawImage(3, 17, 10)

			gfx.setColor(gfx.kColorBlack)
			gfx.drawLine(12, 40, 115, 40)
			gfx.setFont(fontText)
			local bestTime = self.context.player:hasPlayed(self.context.puzzle) or lastTime
			gfx.drawText(
				string.format("Time: %02d:%02d", math.floor(lastTime / 60), lastTime % 60),
				23, 49,
				fontText
			)
			gfx.drawText(
				string.format("Best: %02d:%02d", math.floor(bestTime / 60), bestTime % 60),
				19, 69,
				fontText
			)
		else
			imgMode:drawImage(3, 17, 24)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Time:update()
	if self.animator then
		self:setImage(
			self.image:fadedImage(self.animator:currentValue(), gfx.image.kDitherTypeFloydSteinberg)
		)
		if self.animator:ended() then
			self.animator = nil
		end
	end
end
