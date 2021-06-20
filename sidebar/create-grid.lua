class("CreateGridSidebar").extends(Sidebar)

function CreateGridSidebar:init()
	CreateGridSidebar.super.init(self)
end

function CreateGridSidebar:enter(context)
	local config = {
		menuItems = {
			{
				text = "Test and Save",
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Invert colors",
				exec = function()
					context.screen:invertBoard()
				end
			}
		}
	}

	CreateGridSidebar.super.enter(
		self,
		config,
		not playdate.isCrankDocked(),
		context.player.avatar
	)
end
