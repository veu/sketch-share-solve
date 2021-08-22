class("TutorialSidebar").extends(Sidebar)

function TutorialSidebar:init()
	TutorialSidebar.super.init(self)
end

function TutorialSidebar:enter(context, selected)
	local config = {
		menuTitle = "Solve tutorial",
		menuItems = {
			{
				text = "Show",
				exec = function()
					closeSidebar()
				end
			},
		}
	}

	TutorialSidebar.super.enter(
		self,
		context,
		config
	)
end
