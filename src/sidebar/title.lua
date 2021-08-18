class("TitleSidebar").extends(Sidebar)

function TitleSidebar:init()
	TitleSidebar.super.init(self)
end

function TitleSidebar:enter(context, selected)
	local config = {
		menuItems = {
			{
				text = "Start",
				exec = function ()
					self.onPlay()
				end
			},
			{
				text = "Quick solve",
				selected = selected == ACTION_ID_QUICK_PLAY,
				exec = function ()
					self.onQuickPlay()
				end
			},
			{
				text = "Settings",
				selected = selected == ACTION_ID_SETTINGS,
				exec = function ()
					self.onSettings()
				end
			},
			{
				text = "Tutorials",
				selected = selected == ACTION_ID_TUTORIALS,
				exec = function ()
					self.onTutorials()
				end
			},
		}
	}

	TitleSidebar.super.enter(self, context, config)
end
