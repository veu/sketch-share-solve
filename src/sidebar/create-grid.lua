class("CreateGridSidebar").extends(Sidebar)

function CreateGridSidebar:init()
	CreateGridSidebar.super.init(self)
end

function CreateGridSidebar:enter(context)
	local config = {
		menuItems = {
			{
				text = "Test and Save",
				disabled = context.level:isTrivial(),
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
		context.player.avatar
	)
end
