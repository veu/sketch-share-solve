class("CreateAvatarSidebar").extends(Sidebar)

function CreateAvatarSidebar:init()
	CreateAvatarSidebar.super.init(self)
end

function CreateAvatarSidebar:enter(context)
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
				exec = function()
					context.screen:invertBoard()
				end
			},
			{
				text = "Reset avatar",
				exec = function()
					context.screen:resetBoard()
				end
			}
		}
	}

	CreateAvatarSidebar.super.enter(self, context, config)
end
