class("TestPuzzleSidebar").extends(Sidebar)

function TestPuzzleSidebar:init()
	TestPuzzleSidebar.super.init(self)
end

function TestPuzzleSidebar:enter(context, selected)
	local config = {
		player = context.player.avatar,
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
			},
			{
				text = "Restart",
				disabled = context.puzzle.hasBeenSolved,
				selected = selected == ACTION_ID_RESET_GRID,
				exec = function()
					self.onResetGrid()
				end
			}
		}
	}

	TestPuzzleSidebar.super.enter(self, context, config)
end
