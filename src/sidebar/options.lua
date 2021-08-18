class("OptionsSidebar").extends(Sidebar)

function OptionsSidebar:init()
	OptionsSidebar.super.init(self)
end

function OptionsSidebar:enter(context, selected)
	local hintsText = "Hints: " .. HINTS_TEXT[context.player.options.showHints]
	local timerText = "Timer: " .. (
		context.player.options.showTimer and "on" or "off"
	)
	local config = {
		player = context.player.avatar,
		menuTitle = "Options",
		menuItems = {
			{
				text = hintsText,
				exec = function ()
					self.onToggleHints()
				end,
				execLeft = function ()
					self.onHintsDown()
				end,
				execRight = function ()
					self.onHintsUp()
				end
			},
			{
				text = timerText,
				selected = selected == ACTION_ID_TOGGLE_TIMER,
				exec = function ()
					self.onToggleTimer()
				end,
				execLeft = function ()
					self.onToggleTimer()
				end,
				execRight = function ()
					self.onToggleTimer()
				end
			}
		}
	}

	if context.player:getNumPlayed() > 0 then
		table.insert(config.menuItems, {
			text = "Reset progress",
			selected = selected == OPTION_ID_RESET_PROGRESS,
			exec = function ()
				self.onResetProgress()
			end
		})
	end

	table.insert(config.menuItems, {
		text = "Rename profile",
		selected = selected == OPTION_ID_RENAME_PROFILE,
		exec = function ()
			self.onRename()
		end
	})

	table.insert(config.menuItems, {
		text = "Delete profile",
		exec = function ()
			self.onDelete()
		end
	})

	OptionsSidebar.super.enter(
		self,
		context,
		config
	)
end
