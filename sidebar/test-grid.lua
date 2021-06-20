class("TestGridSidebar").extends(Sidebar)

function TestGridSidebar:init()
	TestGridSidebar.super.init(self)
end

function TestGridSidebar:enter(context)
	local config = {
		menuItems = {
			{
				text = "Edit",
				exec = function()
					self.onAbort()
				end
			}
		}
	}

	TestGridSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar
	)
end
