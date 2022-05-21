class("Collection").extends(gfx.sprite)

function Collection:init()
	Collection.super.init(self, gfx.image.new(400, 240, gfx.kColorWhite))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function Collection:enter(context)
	local player = context.player
	local creator = context.creator
	gfx.lockFocus(self:getImage())
	do
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 400, 240)
		gfx.drawText(creator.name .. "’s\nPuzzle Collection", SIDEBAR_WIDTH + 12, 30)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawLine(SIDEBAR_WIDTH + 10, 65, 400 - 10, 65)
		if creator.id == context.player.id then
			gfx.drawText("Created: " .. #creator.created, SIDEBAR_WIDTH + 12, 74)
		else
			gfx.drawText("Solved: " .. player:getNumPlayedBy(creator) .. " / " .. #creator.created, SIDEBAR_WIDTH + 12, 74)
		end

		if player.options.showTimer then
			local timeSpent = (player:getTimeSpentWith(creator) + 30) // 60
			gfx.drawText(string.format("Solve time: %dh %dm", timeSpent // 60, timeSpent % 60), SIDEBAR_WIDTH + 12, 96)
		end

		if creator.createdOn then
			gfx.drawTextAligned("Created " .. creator.createdOn, 400 - 10, 221, kTextAlignment.right)
		end
	end
	gfx.unlockFocus()
	self:moveTo(0, 0)
	self:add()
end

function Collection:leave()
	self:remove()
end
