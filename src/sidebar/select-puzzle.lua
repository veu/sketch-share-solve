local gfx <const> = playdate.graphics

class("SelectPuzzleSidebar").extends(Sidebar)

function SelectPuzzleSidebar:init()
	SelectPuzzleSidebar.super.init(self)
end

function SelectPuzzleSidebar:enter(context, selected)
	local creator = context.creator
	local numCreated = #creator.created

	local config = {
		player = context.player.avatar,
		creator = creator.avatar,
		menuItems = table.create(numCreated, 0),
		menuTitle = "Select a puzzle",
	}

	local text = "[ Puzzle ]"
	for i, id in pairs(creator.created) do
		config.menuItems[i] = {
			text = text,
			selected = id == selected
		}
	end

	SelectPuzzleSidebar.super.enter(self, context, config)

	self.context = context
	self.selected = selected

	local start = self.list.position
	for i = self.list.position, math.min(numCreated, self.list.position + 5) do
		self:addItem(i)
	end
	self.list.needsRedraw = true

	self.lastLoaded = 0
	self.finishedLoading = numCreated <= 6
end

function SelectPuzzleSidebar:update()
	SelectPuzzleSidebar.super.update(self)

	if not self.finishedLoading then
		local i = self.lastLoaded + 1
		if i <= #self.context.creator.created then
			self:addItem(i)
			self.lastLoaded = i
		else
			self.finishedLoading = true
			self.list.needsRedraw = true
		end
	end
end

function SelectPuzzleSidebar:addItem(i)
	local player = self.context.player
	local creator = self.context.creator
	local id = creator.created[i]
	local puzzle = Puzzle.load(self.context, id, creator._save)
	local revealed = creator.id == player.id or player:hasPlayed(puzzle)
	local text = revealed and puzzle.title or string.format("[ Puzzle %02d ]", i)

	local image = nil
	if revealed then
		image = createPuzzlePreview(puzzle)
	end

	self.menuItems[i] = {
		text = text,
		ref = puzzle,
		img = image,
		selected = puzzle.id == self.selected
	}
end
