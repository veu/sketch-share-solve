local gfx <const> = playdate.graphics

class("CreatorAvatar").extends(gfx.sprite)

function CreatorAvatar:init()
	CreatorAvatar.super.init(self)

	self.text = "Creator"
	self.image = gfx.image.new(SIDEBAR_WIDTH + 1, 28, gfx.kColorClear)
	self:setImage(self.image)
	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_AVATAR)

	self:moveTo(self.x, 240 - 2)
end

function CreatorAvatar:enter(config, avatar)
	self.menuItems = config.menuItems
	self.idleCounter = 0
	self.position = 1
	self.slide = nil

	if avatar then
		self:draw(avatar)
	end
	if not self.avatar and avatar then
		self.showAnimator = gfx.animator.new(
			400,
			0,
			25,
			playdate.easingFunctions.inOutSine
		)
	elseif self.avatar and not avatar then
		self.showAnimator = gfx.animator.new(
			400,
			25,
			0,
			playdate.easingFunctions.inOutSine
		)
	end
	self.avatar = avatar

	self:add()
end

function CreatorAvatar:leave()
end

function CreatorAvatar:change(position)
	self.idleCounter = 0
	self.animator = nil

	self:setPosition(position)
end

function CreatorAvatar:setPosition(position)
	self.position = position
	self.target = math.floor(position + 0.5)

	self:initSlide()

	self:draw()
end

function CreatorAvatar:setTarget(position)
	self.target = position
	self.animator = nil
	self.idleCounter = 5

	self:initSlide()
end

function CreatorAvatar:draw(avatar)
	self.image:clear(gfx.kColorClear)
	gfx.pushContext(self.image)
	do
		gfx.setColor(gfx.kColorWhite)
		gfx.drawLine(0, 1, SIDEBAR_WIDTH - SEPARATOR_WIDTH - 1, 1)
		gfx.drawLine(SIDEBAR_WIDTH - SEPARATOR_WIDTH + 1, 1, SIDEBAR_WIDTH, 1)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawLine(SIDEBAR_WIDTH - SEPARATOR_WIDTH + 1, 0, SIDEBAR_WIDTH - 1, 0)
		drawRightTextRect(-1, 2, SIDEBAR_WIDTH - 23, 26, self.text)
		gfx.setDrawOffset(AVATAR_OFFSET, 2)
		if avatar then
			avatar:drawScaled(3, 3, 2)
		else
			gfx.setClipRect(0, 0, 26, 26)
			self.slide:draw(3, 3 - math.floor((self.position - 1) * 23 + 0.5))
		end
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRect(0, 0, 26, 26)
		gfx.drawRect(2, 2, 22, 22)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(1, 1, 24, 24)
	end
	gfx.popContext()
	self:markDirty()
end

function CreatorAvatar:initSlide()
	if not self.slide then
		self.slide = gfx.image.new(20, 23 * #self.menuItems, gfx.kColorClear)
		gfx.lockFocus(self.slide)
		for i, item in pairs(self.menuItems) do
			if item.avatar == self.avatar then
				self.position = i
			end
			item.avatar:drawScaled(0, (i - 1) * 23, 2)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawRect(0, (i - 1) * 23 + 20, 20, 3)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawLine(0, (i - 1) * 23 + 21, 20, (i - 1) * 23 + 21)
		end
		gfx.unlockFocus()
	end
end

function CreatorAvatar:update()
	if self.showAnimator then
		self:moveTo(self.x, 240 - 2 - math.floor(self.showAnimator:currentValue() + 0.5))
		if self.showAnimator:ended() then
			self.showAnimator = nil
		end
	end
	if self.slide and self.position ~= self.target then
		self.idleCounter += 1
		if self.animator then
			self:setPosition(self.animator:currentValue())
			if self.animator:ended() then
				self.animator = nil
			end
		elseif self.idleCounter >= 5 then
			self.animator = gfx.animator.new(
				200,
				self.position,
				self.target,
				playdate.easingFunctions.inOutSine
			)
		end
	end
end

