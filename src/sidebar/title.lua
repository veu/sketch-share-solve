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
				text = "Tutorial",
				disabled = true,
			},
			{
				text = "Settings",
				disabled = true,
			},
		}
	}

	SelectModeSidebar.super.enter(self, context, config)
end
