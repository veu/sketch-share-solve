class("SaveGridSidebar").extends(Sidebar)

function SaveGridSidebar:init()
	SaveGridSidebar.super.init(self)
end

function SaveGridSidebar:enter(context)
	local config = {
		menuTitle = "Name your puzzle",
		menuItems = {
			{
				text = context.level.title,
				img = createLevelPreview(context.level)
			}
		},
		stayOpen = true
	}

	SaveGridSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
