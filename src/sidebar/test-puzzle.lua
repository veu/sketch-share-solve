class("TestPuzzleSidebar").extends(Sidebar)

function TestPuzzleSidebar:init()
	TestPuzzleSidebar.super.init(self)
end

function TestPuzzleSidebar:enter(context, selected)
	local config = {
		player = context.player.avatar,
		menuTitle = "Solve and save puzzle",
		menuItems = {
			{
				text = context.puzzle.hasBeenSolved and "See solution" or "Solve",
				exec = function()
					closeSidebar()
				end
			}
		}
	}

	if context.puzzle.hasBeenSolved then
		table.insert(config.menuItems, {
			text = "Rotate solution",
			selected = selected == ACTION_ID_ROTATE,
			img = createPuzzlePreview(context.puzzle),
			exec = function()
				self.onRotatePuzzle()
			end
		})
	else
		table.insert(config.menuItems, {
			text = "Hint style: " .. NUM_STYLE_NAMES[context.settings.hintStyle],
			selected = selected == ACTION_ID_HINT_STYLE,
			img = createHintStylePreview(context.settings.hintStyle),
			exec = function ()
				self.onHintStyleNext()
			end,
			execLeft = function ()
				self.onHintStylePrevious()
			end,
			execRight = function ()
				self.onHintStyleNext()
			end
		})
	end

	table.insert(config.menuItems, {
		text = "Save",
		disabled = not context.puzzle.hasBeenSolved,
		disabledText = "Please solve the puzzle once before saving to assure that it has only one solution.",
		exec = function()
			self.onSave()
		end
	})

	table.insert(config.menuItems, {
		text = "Edit",
		exec = function()
			self.onAbort()
		end
	})

	if not context.puzzle.hasBeenSolved then
		table.insert(config.menuItems, {
			text = "Restart",
			selected = selected == ACTION_ID_RESET_GRID,
			exec = function()
				self.onResetGrid()
			end
		})
	end

	TestPuzzleSidebar.super.enter(self, context, config)
end
