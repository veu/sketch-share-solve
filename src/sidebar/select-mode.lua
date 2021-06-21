class("SelectModeSidebar").extends(Sidebar)

function SelectModeSidebar:init()
	SelectModeSidebar.super.init(self)
end

function SelectModeSidebar:enter(context)
	local config = {
		menuItems = {
			{ text = "Play", ref = MODE_PLAY },
			{ text = "Create", ref = MODE_CREATE },
		}
	}

	SelectModeSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar
	)
end
