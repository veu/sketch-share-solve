class("CreateAvatarSidebar").extends(Sidebar)

function CreateAvatarSidebar:init()
	CreateAvatarSidebar.super.init(self)
end

function CreateAvatarSidebar:enter(context, selected)
	local config = {
		player = createAvatarPreview(context.puzzle) or imgAvatars:getImage(AVATAR_ID_NIL),
		menuTitle = "Create new avatar",
		menuItems = {
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

	CreateAvatarSidebar.super.enter(self, context, config)
end
