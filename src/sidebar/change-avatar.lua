class("ChangeAvatarSidebar").extends(Sidebar)

function ChangeAvatarSidebar:init()
	ChangeAvatarSidebar.super.init(self)
end

function ChangeAvatarSidebar:enter(context, selected)
	local config = {
		player = createAvatarPreview(context.puzzle) or context.player.avatar,
		menuTitle = "Change avatar",
		menuItems = {
			{
				text = "Sketch",
				exec = function()
					closeSidebar()
				end
			},
			{
				text = "Save",
				exec = function()
					self.onSave()
				end
			},
			{
				text = "Invert colors",
				selected = selected == ACTION_ID_INVERT_COLORS,
				exec = function()
					self.onInvertGrid()
				end
			},
			{
				text = "Reset avatar",
				selected = selected == ACTION_ID_RESET_GRID,
				exec = function()
					self.onResetGrid()
				end
			}
		}
	}

	ChangeAvatarSidebar.super.enter(self, context, config)
end
