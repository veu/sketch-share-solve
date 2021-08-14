local gfx <const> = playdate.graphics

class("Time").extends(gfx.sprite)

function Time:init()
	Time.super.init(self)

	self.image = gfx.image.new(127, 72, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TIMER)
	self:moveTo(25, 0)
end

function Time:enter(context)
	self.context = context
	self:redraw()
	self:add()
end

function Time:leave()
	self:remove()
end

function Time:redraw()
	self.image:clear(gfx.kColorClear)
	gfx.lockFocus(self.image)
	do
		if self.context.player.options.showTimer then
			imgMode:drawImage(MODE_PLAY, 17, 10)

			gfx.setColor(gfx.kColorBlack)
			gfx.drawLine(12, 40, 115, 40)
			gfx.setFont(fontText)
			local time = self.context.player.lastTime
			gfx.drawText(
				string.format("%02d:%02d", math.floor(time / 60), time % 60),
				45, 29 + 20,
				fontText
			)
		else
			imgMode:drawImage(MODE_PLAY, 17, 24)
		end
	end
	gfx.unlockFocus()
	self:markDirty()
end
