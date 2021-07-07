class("CreatePuzzleSidebar").extends(Sidebar)

function CreatePuzzleSidebar:init()
	CreatePuzzleSidebar.super.init(self)
end

function CreatePuzzleSidebar:enter(context, selected)
	local config = {
		player = context.player.avatar,
		menuItems = {
			{
				text = "Test and save",
				disabled = context.puzzle:isTrivial(),
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Invert colors",
				selected = selected == ACTION_ID_INVERT_COLORS,
				exec = function()
					self.onInvertColors()
				end
			},
			{
				text = "Reset grid",
				selected = selected == ACTION_ID_RESET_GRID,
				exec = function()
					self.onResetGrid()
				end
			}
		}
	}

	CreatePuzzleSidebar.super.enter(self, context, config)
end
