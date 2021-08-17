local gfx <const> = playdate.graphics

class("NamePuzzleSidebar").extends(Sidebar)

function NamePuzzleSidebar:init()
	NamePuzzleSidebar.super.init(self)
end

function NamePuzzleSidebar:enter(context, selected)
	local player = context.player

	local config = {
		player = player.avatar,
		creator = player.avatar,
		menuItems = {},
		menuTitle = "Name your puzzle",
		stayOpen = true,
	}

	local numCreated = #player.created
	for i = math.max(1, numCreated - 4), numCreated do
		local id = player.created[i]
		local puzzle = Puzzle.load(context, id)

		table.insert(config.menuItems, {
			text = puzzle.title,
			ref = puzzle,
			img = createPuzzlePreview(puzzle),
		})
	end

	table.insert(config.menuItems, {
		text = context.puzzle.title,
		img = createPuzzlePreview(context.puzzle),
		selected = true,
		showCursor = true,
	})

	NamePuzzleSidebar.super.enter(self, context, config)
	self.list.highlightUpdate = nil
end
