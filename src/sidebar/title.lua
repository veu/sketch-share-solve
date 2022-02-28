class("TitleSidebar").extends(Sidebar)

function TitleSidebar:init()
	TitleSidebar.super.init(self)
end

function TitleSidebar:enter(context, selected)
	local config = {
		menuItems = {
			{
				text = "Start",
				exec = function ()
					self.onPlay()
				end
			}
		}
	}

	if context.ext.rdk then
		table.insert(config.menuItems, {
			text = "Quick solve",
			selected = selected == ACTION_ID_QUICK_PLAY,
			exec = function ()
				self.onQuickPlay()
			end
		})
	end

	table.insert(config.menuItems, {
		text = "Settings",
		selected = selected == ACTION_ID_SETTINGS,
		exec = function ()
			self.onSettings()
		end
	})

	table.insert(config.menuItems, {
		text = "Tutorials",
		selected = selected == ACTION_ID_TUTORIALS,
		exec = function ()
			self.onTutorials()
		end
	})

	table.insert(config.menuItems, {
		text = "About",
		selected = selected == ACTION_ID_ABOUT,
		exec = function ()
			self.onAbout()
		end
	})

	TitleSidebar.super.enter(self, context, config)
end
