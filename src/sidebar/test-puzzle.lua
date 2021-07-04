class("TestPuzzleSidebar").extends(Sidebar)

function TestPuzzleSidebar:init()
	TestPuzzleSidebar.super.init(self)
end

function TestPuzzleSidebar:enter(context)
	local config = {
		menuItems = {
			{
				text = "Save",
				disabled = not context.puzzle.hasBeenSolved,
				exec = function()
					self.onSave()
				end
			},
			{
				text = "Edit",
				exec = function()
					self.onAbort()
				end
			}
		}
	}

	TestPuzzleSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
