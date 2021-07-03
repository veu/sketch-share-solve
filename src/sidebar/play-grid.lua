class("PlayGridSidebar").extends(Sidebar)

function PlayGridSidebar:init()
	PlayGridSidebar.super.init(self)
end

function PlayGridSidebar:enter(context)
	local player = context.player
	local creator = context.creator
	local level = context.level
	local config = {
		menuTitle = "\"" .. self:getTitle(player, creator, level) .. "\"",
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

	PlayGridSidebar.super.enter(
		self,
		config,
		player.avatar,
		creator.avatar
	)
end

function PlayGridSidebar:getTitle(player, creator, level)
	if creator.id == player.id or player.played[level.id] then
		return level.title
	end

	for i, id in pairs(creator.created) do
		if id == level.id then
			return "Puzzle " .. i
		end
	end
end
