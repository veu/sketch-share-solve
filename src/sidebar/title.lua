class("TitleSidebar").extends(Sidebar)

function TitleSidebar:init()
	TitleSidebar.super.init(self)
end

function TitleSidebar:enter(context, selected)
	local config = {
		menuItems = {
			{
				text = "Play",
				exec = function ()
					self.onPlay()
				end
			},
		}
	}

	SelectModeSidebar.super.enter(self, context, config)
end
