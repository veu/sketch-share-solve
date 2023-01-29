class("CreatePuzzleSidebar").extends(Sidebar)

function CreatePuzzleSidebar:init()
	CreatePuzzleSidebar.super.init(self)
end

function CreatePuzzleSidebar:enter(context, selected, same)
	local config = {
		player = context.player.avatar,
		menuTitle = "Create new puzzle",
		menuItems = {
			{
				text = "Sketch",
				exec = function()
					closeSidebar()
				end
			},
			{
				text = "Solve and save",
				disabled = context.puzzle:isTrivial(),
				disabledText = "Please draw something before saving.",
				exec = function()
					self.onTestAndSave()
				end
			},
			{
				text = "Undo",
				selected = selected == ACTION_ID_UNDO,
				exec = function()
					self.onUndo()
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
				text = "Flip horizontally",
				selected = selected == ACTION_ID_FLIP,
				exec = function()
					self.onFlip()
				end
			},
			{
				text = "Flip vertically",
				selected = selected == ACTION_ID_FLIP_Y,
				exec = function()
					self.onFlipY()
				end
			},
			{
				text = "Reset",
				selected = selected == ACTION_ID_RESET_GRID,
				exec = function()
					self.onResetGrid()
				end
			}
		}
	}

	CreatePuzzleSidebar.super.enter(self, context, config, nil, nil, same)
end
