local gfx <const> = playdate.graphics

class("SelectLevelSidebar").extends(Sidebar)

function SelectLevelSidebar:init()
	SelectLevelSidebar.super.init(self)
end

function SelectLevelSidebar:enter(context)
	local player = context.player
	local creator = context.creator
	local menuItems = {}
	for i, id in pairs(creator.created) do
		local level = Level.load(context, id)
		local revealed = creator.id == player.id or player.played[level.id]
		local text = revealed and level.title or "Level " .. i

		local image = nil
		if revealed then
			image = createLevelPreview(level)
		end

		table.insert(menuItems, {
			text = text,
			ref = level,
			img = image
		})
	end

	local config = {
		menuItems = menuItems,
		menuTitle = "Choose level"
	}

	SelectLevelSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar,
		context.creator.avatar
	)
end
