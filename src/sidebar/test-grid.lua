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
			},
			{
				text = "Save",
				disabled = not context.level.hasBeenSolved,
				exec = function()
					self.onSave()
				end
			}
		}
	}

	TestGridSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
