class("NamePlayerSidebar").extends(Sidebar)

function NamePlayerSidebar:init()
	NamePlayerSidebar.super.init(self)
end

function NamePlayerSidebar:enter(context)
	local config = {
		menuTitle = "Choose a name",
		menuItems = {
			{
				text = context.player.name
			}
		},
		stayOpen = true
	}

	NamePlayerSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
