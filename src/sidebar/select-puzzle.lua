local gfx <const> = playdate.graphics

class("SelectPuzzleSidebar").extends(Sidebar)

function SelectPuzzleSidebar:init()
	SelectPuzzleSidebar.super.init(self)
end

function SelectPuzzleSidebar:enter(context, selected)
	local player = context.player
	local creator = selected == PUZZLE_ID_SHOW_NAME and player or context.creator

	local config = {
		player = player.avatar,
		creator = creator.avatar,
		menuItems = {},
		menuTitle = selected == PUZZLE_ID_SHOW_NAME and "Name your puzzle" or "Select a puzzle",
		stayOpen = selected == PUZZLE_ID_SHOW_NAME
	}

	for i, id in pairs(creator.created) do
		local puzzle = Puzzle.load(context, id)
		local revealed = creator.id == player.id or player.played[puzzle.id]
		local text = revealed and "\"" .. puzzle.title .. "\"" or "Puzzle " .. i

		local image = nil
		if revealed then
			image = createPuzzlePreview(puzzle)
		end

		table.insert(config.menuItems, {
			text = text,
			ref = puzzle,
			img = image,
			selected = puzzle.id == selected
		})
	end

	if selected == PUZZLE_ID_SHOW_NAME then
		table.insert(config.menuItems, {
			text = context.puzzle.title,
			img = createPuzzlePreview(context.puzzle),
			selected = true,
			showCursor = true,
		})
	end

	SelectPuzzleSidebar.super.enter(self, context, config)
end
