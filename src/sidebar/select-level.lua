local gfx <const> = playdate.graphics

class("SelectLevelSidebar").extends(Sidebar)

function SelectLevelSidebar:init()
	SelectLevelSidebar.super.init(self)
end

function SelectLevelSidebar:enter(context, selected)
	local config = {
		menuItems = {},
		menuTitle = selected == LEVEL_ID_SHOW_NAME and "Name your puzzle" or "Choose puzzle",
		stayOpen = selected == LEVEL_ID_SHOW_NAME
	}

	local player = context.player
	local creator = selected == LEVEL_ID_SHOW_NAME and player or context.creator
	for i, id in pairs(creator.created) do
		local level = Level.load(context, id)
		local revealed = creator.id == player.id or player.played[level.id]
		local text = revealed and level.title or "Puzzle " .. i

		local image = nil
		if revealed then
			image = createLevelPreview(level)
		end

		table.insert(config.menuItems, {
			text = text,
			ref = level,
			img = image,
			selected = level.id == selected
		})
	end

	if selected == LEVEL_ID_SHOW_NAME then
		table.insert(config.menuItems, {
			text = context.level.title,
			img = createLevelPreview(context.level),
			selected = true,
		})
	end

	SelectLevelSidebar.super.enter(
		self,
		config,
		context.player.avatar,
		creator.avatar
	)
end
