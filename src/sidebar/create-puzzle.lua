class("CreatePuzzleSidebar").extends(Sidebar)

function CreatePuzzleSidebar:init()
	CreatePuzzleSidebar.super.init(self)
end

function CreatePuzzleSidebar:enter(context)
	local config = {
		menuItems = {
			{
				text = "Test and Save",
				disabled = context.puzzle:isTrivial(),
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Invert colors",
				exec = function()
					context.screen:invertBoard()
				end
			},
			{
				text = "Reset grid",
				exec = function()
					context.screen:resetBoard()
				end
			}
		}
	}

	CreatePuzzleSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
