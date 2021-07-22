class("PlayPuzzleSidebar").extends(Sidebar)

function PlayPuzzleSidebar:init()
	PlayPuzzleSidebar.super.init(self)
end

function PlayPuzzleSidebar:enter(context)
	local player = context.player
	local creator = context.creator
	local puzzle = context.puzzle
	local config = {
		player = player.avatar,
		creator = creator.avatar,
		menuTitle = self:getTitle(player, creator, puzzle),
		menuItems = {
			{
				text = "Reset grid",
				disabled = puzzle.hasBeenSolved,
				exec = function()
					context.screen:resetGrid()
				end
			}
		}
	}

	if puzzle.hasBeenSolved and player.id == PLAYER_ID_QUICK_PLAY then
		table.insert(config.menuItems, {
			text = "Solve another",
			exec = function()
				self.onNext()
			end
		})
	end

	if creator.id == player.id then
		table.insert(config.menuItems, {
			text = "Delete puzzle",
			exec = function()
				self.onDeletePuzzle()
			end
		})
	end

	PlayPuzzleSidebar.super.enter(self, context, config)
end

function PlayPuzzleSidebar:getTitle(player, creator, puzzle)
	if creator.id == player.id or player:hasPlayed(puzzle) then
		return "\"" .. puzzle.title .. "\""
	end

	for i, id in pairs(creator.created) do
		if id == puzzle.id then
			return string.format("Puzzle %02d", i)
		end
	end
end
