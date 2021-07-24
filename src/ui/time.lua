local gfx <const> = playdate.graphics

class("Time").extends(gfx.sprite)

function Time:init()
	Time.super.init(self)

	self.image = gfx.image.new(40, 16, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TIMER)
	self:moveTo(70, 29)
end

function Time:enter(context)
	if context.player.options.showTimer then
		self.current = math.min(5940, context.player.lastTime)
		self:redraw()
		self:add()
	end
end

function Time:leave()
	self:remove()
end

function Time:redraw()
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
