class("TextCursor").extends(gfx.sprite)

function TextCursor:init()
	self.image = gfx.image.new(1, 14, gfx.kColorBlack)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TEXT_CURSOR)

	self.blinker = gfx.animation.blinker.new()
	self.blinker.loop = true
	self.blinker.onDuration = 300
	self.blinker.offDuration = 300
end

function TextCursor:enter(x, y)
	self:moveTo(x, y)
	self:add()
	self.blinker:start()
end

function TextCursor:leave()
	self.blinker:stop()
	self:remove()
end

function TextCursor:update()
	self.blinker:update()
	self:setVisible(self.blinker.on)
end
