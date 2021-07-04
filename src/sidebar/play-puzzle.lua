class("PlayPuzzleSidebar").extends(Sidebar)

function PlayPuzzleSidebar:init()
	PlayPuzzleSidebar.super.init(self)
end

function PlayPuzzleSidebar:enter(context)
	local player = context.player
	local creator = context.creator
	local puzzle = context.puzzle
	local config = {
		menuTitle = self:getTitle(player, creator, puzzle),
		menuItems = {
			{
				text = "Reset grid",
				exec = function()
					context.screen:resetBoard()
				end
			}
		}
	}

	if creator.id == player.id then
		table.insert(config.menuItems, {
			text = "Delete puzzle",
			exec = function()
				self.onDeletePuzzle()
			end
		})
	end

	PlayPuzzleSidebar.super.enter(
		self,
		config,
		player.avatar,
		creator.avatar
	)
end

function PlayPuzzleSidebar:getTitle(player, creator, puzzle)
	if creator.id == player.id or player.played[puzzle.id] then
		return "\"" .. puzzle.title .. "\""
	end

	for i, id in pairs(creator.created) do
		if id == puzzle.id then
			return "Puzzle " .. i
		end
	end
end
