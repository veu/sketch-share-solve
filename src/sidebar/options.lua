class("OptionsSidebar").extends(Sidebar)

function OptionsSidebar:init()
	OptionsSidebar.super.init(self)
end

function OptionsSidebar:enter(context)
	local hintsText = "Hints: " .. (
		context.player.options.hintsDisabled and "off" or "on"
	)
	local config = {
		menuItems = {
			{
				text = hintsText,
				exec = function ()
					self.onToggleHints()
				end
			},
			{
				text = "Rename profile",
				exec = function ()
					self.onRename()
				end
			},
		}
	}

	OptionsSidebar.super.enter(
		self,
		config,
		context.player.avatar
	)
end
