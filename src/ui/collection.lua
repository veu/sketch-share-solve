class("Collection").extends(gfx.sprite)

function Collection:init()
	Collection.super.init(self, gfx.image.new(400, 240, gfx.kColorWhite))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function Collection:enter(context)
	self.player = context.player
	self:redraw()
end

function Collection:redraw()
	if not self.player or not self.creator then
		return
	end

	local player <const> = self.player
	local creator <const> = self.creator

	gfx.lockFocus(self:getImage())
	do
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 400, 240)
		gfx.drawText(creator.name .. "’s\nPuzzle Collection", SIDEBAR_WIDTH + 12, 16)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawLine(SIDEBAR_WIDTH + 10, 51, 400 - 10, 51)
		if creator.id == player.id then
			gfx.drawText("Created: " .. #creator.created, SIDEBAR_WIDTH + 12, 60)
		else
			gfx.drawText("Solved: " .. player:getNumPlayedBy(creator) .. " / " .. #creator.created, SIDEBAR_WIDTH + 12, 60)
		end

		if player.options.showTimer then
			local timeSpent = (player:getTimeSpentWith(creator) + 30) // 60
			gfx.drawText(string.format("Solve time: %dh %dm", timeSpent // 60, timeSpent % 60), SIDEBAR_WIDTH + 12, 82)
		end

		if creator.createdOn then
			gfx.drawText("Created " .. creator.createdOn, SIDEBAR_WIDTH + 12, 221)
		end
	end
	gfx.unlockFocus()
	self:moveTo(0, 0)
	self:add()
end

function Collection:leave()
	self:remove()
end

function Collection:setCreator(creator)
	self.creator = creator
	self:redraw()
end
