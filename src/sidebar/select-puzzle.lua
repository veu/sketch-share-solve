class("SelectPuzzleSidebar").extends(Sidebar)

function SelectPuzzleSidebar:init()
	SelectPuzzleSidebar.super.init(self)
end

function SelectPuzzleSidebar:enter(context, selected)
	local creator = context.creator
	local numCreated = #creator.created
	local player = context.player

	local config = {
		player = player.avatar,
		creator = creator.avatar,
		menuItems = table.create(numCreated, 0),
		menuTitle = "Select a puzzle",
	}

	local text = "[ Puzzle ]"
	local created = creator.created
	for i = 1, #created do
		local puzzleId = created[i]
		if not selected and player.id ~= creator.id and not player:hasPlayedId(puzzleId, creator) then
			selected = puzzleId
		end
		config.menuItems[i] = {
			text = text,
			selected = puzzleId == selected
		}
	end

	SelectPuzzleSidebar.super.enter(self, context, config)

	self.context = context
	self.selected = selected

	local start = self.list.position
	for i = start, math.min(numCreated, start + 5) do
		self:addItem(i)
		if i == self.list.cursor then
			local menuItem <const> = self.menuItems[i]
			self.onNavigated(menuItem.ref, menuItem.img)
		end
	end
	self.list.needsRedraw = true

	self.lastLoaded = 0
	self.finishedLoading = numCreated <= 6
end

function SelectPuzzleSidebar:update()
	SelectPuzzleSidebar.super.update(self)

	if not self.finishedLoading then
		for i = self.lastLoaded + 1, math.min(#self.context.creator.created, self.lastLoaded + 2) do
			self.lastLoaded = i
			self:addItem(i)
		end

		if self.lastLoaded == #self.context.creator.created then
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
	local text = revealed and puzzle.title or string.format("[ Puzzle %03d ]", i)

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
