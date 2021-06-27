class("SelectModeSidebar").extends(Sidebar)

function SelectModeSidebar:init()
	SelectModeSidebar.super.init(self)
end

function SelectModeSidebar:enter(context)
	local config = {
		menuItems = {
			{ text = "Solve", ref = MODE_PLAY },
			{ text = "Sketch", ref = MODE_CREATE },
		}
	}

	SelectModeSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
