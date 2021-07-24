local gfx <const> = playdate.graphics

class("Timer").extends(gfx.sprite)

function Timer:init()
	Timer.super.init(self)

	self.image = gfx.image.new(40, 16, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TIMER)
	self:moveTo(70, 29)
end

function Timer:enter(context)
	self.show = context.player.options.showTimer
	playdate.resetElapsedTime()
	self.current = 0
	if self.show then
		self:redraw()
	else
		self.image:clear(gfx.kColorClear)
	end
	self:add()
end

function Timer:leave()
	self:remove()
end

function Timer:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		gfx.setFont(fontText)
		gfx.drawText(
			string.format("%02d:%02d", math.floor(self.current / 60), self.current % 60),
			0, 0,
			fontText
		)
	end
	gfx.unlockFocus()
	self:markDirty()
end

function Timer:update()
	local elapsed = math.min(5940, math.floor(playdate.getElapsedTime()))
	if elapsed == self.current then
		return
	end
	self.current = elapsed
	if self.show then
		self:redraw()
	end
end
