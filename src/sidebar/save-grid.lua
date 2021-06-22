class("SaveGridSidebar").extends(Sidebar)

function SaveGridSidebar:init()
	SaveGridSidebar.super.init(self)
end

function SaveGridSidebar:enter(context)
	local config = {
		menuTitle = "Choose name",
		menuItems = {
			{
				text = context.level.title,
				img = createLevelPreview(context.level)
			}
		}
	}

	SaveGridSidebar.super.enter(
		self,
		config,
		true,
		context.player.avatar
	)
end

function SaveGridSidebar:open()
	-- needs to stay open until keyboard is closed
end

function SaveGridSidebar:close()
	-- needs to stay open until keyboard is closed
end
