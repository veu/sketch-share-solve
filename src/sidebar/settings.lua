class("SettingsSidebar").extends(Sidebar)

function SettingsSidebar:init()
	SettingsSidebar.super.init(self)
end

function SettingsSidebar:enter(context, selected)
	local config = {
		menuTitle = "Settings",
		menuItems = {
			{
				text = "Crank speed: " .. context.settings.crankSpeed,
				exec = function ()
					self.onCrankSpeedUp()
				end,
				execLeft = function ()
					self.onCrankSpeedDown()
				end,
				execRight = function ()
					self.onCrankSpeedUp()
				end
			},
		}
	}

	SettingsSidebar.super.enter(self, context, config)
end
