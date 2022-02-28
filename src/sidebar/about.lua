class("AboutSidebar").extends(Sidebar)

function AboutSidebar:init()
	AboutSidebar.super.init(self)
end

function AboutSidebar:enter(context, selected)
	local config = {
		menuItems = {
			{
				text = "Show info",
				exec = function()
					closeSidebar()
				end
			}
		}
	}

	AboutSidebar.super.enter(self, context, config)
end
