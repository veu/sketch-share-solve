class("SelectModeSidebar").extends(Sidebar)

function SelectModeSidebar:init()
	SelectModeSidebar.super.init(self)
end

function SelectModeSidebar:enter(context)
	local config = {
		player = context.player.avatar,
		menuTitle = "What do you want to do?",
		menuItems = {
			{ text = "Solve", ref = MODE_PLAY },
			{ text = "Sketch", ref = MODE_CREATE },
			{ text = "Configure", ref = MODE_OPTIONS },
		}
	}

	SelectModeSidebar.super.enter(self, context, config)
end
