class("Timer").extends(gfx.sprite)

function Timer:init()
	Timer.super.init(self, gfx.image.new(127, 72))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TIMER)
	self:moveTo(25, 0)
end

function Timer:enter(show, mode)
	self.show = show
	self.mode = mode
	self.start = math.floor(playdate.getCurrentTimeMilliseconds() / 1000)
	self.current = 0
	self:redraw()
	self:add()
end

function Timer:leave()
	self:remove()
end

function Timer:reset()
	self.start = math.floor(playdate.getCurrentTimeMilliseconds() / 1000)
	self.current = 0
	if self.show then
		self:redraw()
	end
end

function Timer:redraw()
	self:getImage():clear(gfx.kColorClear)
	gfx.lockFocus(self:getImage())
	do
		if self.show then
			imgMode:drawImage(self.mode, 17, 10)

			gfx.setColor(gfx.kColorBlack)
			gfx.drawLine(12, 40, 114, 40)
			gfx.setFont(fontTextBold)
			gfx.drawText("Time:", 20, 49)
			gfx.setFont(fontTime)
			gfx.drawText(
				string.format("%02d:%02d", math.floor(self.current / 60), self.current % 60),
				63, 49
			)
		else
			imgMode:drawImage(self.mode, 17, 24)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Timer:update()
	local elapsed = math.min(5940, math.floor(playdate.getCurrentTimeMilliseconds() / 1000) - self.start)
	if elapsed == self.current then
		return
	end
	self.current = elapsed
	if self.show then
		self:redraw()
	end
end
