class("OptionsSidebar").extends(Sidebar)

function OptionsSidebar:init()
	OptionsSidebar.super.init(self)
end

function OptionsSidebar:enter(context, selected)
	local hintsText = "Hints: " .. (
		context.player.options.hintsDisabled and "off" or "on"
	)
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
					self.onToggleHints()
				end,
				execRight = function ()
					self.onToggleHints()
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
			},
			{
				text = "Reset progress",
				disabled = context.player:getNumPlayed() == 0,
				selected = selected == OPTION_ID_RESET_PROGRESS,
				exec = function ()
					self.onResetProgress()
				end
			},
			{
				text = "Rename profile",
				selected = selected == OPTION_ID_RENAME_PROFILE,
				exec = function ()
					self.onRename()
				end
			},
			{
				text = "Delete profile",
				exec = function ()
					self.onDelete()
				end
			},
		}
	}

	OptionsSidebar.super.enter(
		self,
		context,
		config
	)
end
