class("PuzzlePreview").extends(gfx.sprite)

function PuzzlePreview:init()
	PuzzlePreview.super.init(self, gfx.image.new(400, 240, gfx.kColorWhite))

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_TITLE)
end

function PuzzlePreview:enter(context)
	self.player = context.player
	self.creator = context.creator
	self:redraw()
end

function PuzzlePreview:redraw()
	if not self.creator or not self.puzzle then
		return
	end

	local player <const> = self.player
	local creator <const> = self.creator
	local puzzle <const> = self.puzzle

	gfx.lockFocus(self:getImage())
	do
		imgPreview:drawImage(puzzle.rotation and 2 or 1, 0, 0)

		local timeSpent = player:hasPlayedId(puzzle.id, creator)

		gfx.drawText((player.id == creator.id or timeSpent) and puzzle.title or "???", SIDEBAR_WIDTH + 12, 16)

		if player.options.showTimer then
			if timeSpent then
				gfx.drawText(string.format("Solve time: %dm %ds", timeSpent // 60, timeSpent % 60), SIDEBAR_WIDTH + 12, 44)
			end
		end

		if self.preview then
			if puzzle.rotation == 1 then
				gfx.setClipRect(SIDEBAR_WIDTH + 59, 92, 62, 92)
				self.preview:drawScaled(SIDEBAR_WIDTH + 35, 81, 6)
			elseif puzzle.rotation == 2 then
				gfx.setClipRect(SIDEBAR_WIDTH + 59, 92, 62, 92)
				self.preview:drawScaled(SIDEBAR_WIDTH + 29, 81, 6)
			else
				gfx.setClipRect(SIDEBAR_WIDTH + 44, 107, 92, 62)
				self.preview:drawScaled(SIDEBAR_WIDTH + 32, 84, 6)
			end
		end
	end
	gfx.unlockFocus()
	self:moveTo(0, 0)
	self:add()
end

function PuzzlePreview:leave()
	self:remove()
end

function PuzzlePreview:setInvertedMode(active)
	self:setImageDrawMode(active and gfx.kDrawModeInverted or gfx.kDrawModeCopy)
end

function PuzzlePreview:setPuzzle(puzzle, preview)
	self.puzzle = puzzle
	self.preview = preview
	self:redraw()
end
