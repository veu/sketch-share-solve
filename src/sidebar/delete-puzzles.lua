class("DeletePuzzlesSidebar").extends(Sidebar)

function DeletePuzzlesSidebar:init()
	DeletePuzzlesSidebar.super.init(self)
end

function DeletePuzzlesSidebar:enter(context, selected)
	local config = {
		menuItems = {},
		menuTitle = "Delete puzzles"
	}

	local selectedIndex = nil
	local index = 1
	local creator = nil
	local isEmpty = true
	for _, save in pairs(context.ext) do
		local profileList = save.profileList
		for i = 1, #profileList do
			local profile = Profile.load(context, profileList[i], save)
			if profile.id ~= PLAYER_ID_RDK and #profile.created > 0 then
				isEmpty = false
				if profile.id == selected or not creator then
					selectedIndex = index
					creator = profile
				end
				table.insert(config.menuItems, {
					text = profile.name,
					avatar = profile.avatar,
					ref = profile,
					selected = profile.id == selected,
				})
				index += 1
			end
		end
	end

	if isEmpty then
		table.insert(config.menuItems, {
			text = "Nothing to delete",
			exec = function () end,
		})
	end

	if creator then
		config.creator = creator.avatar
	end

	DeletePuzzlesSidebar.super.enter(self, context, config)
end

function DeletePuzzlesSidebar:onCranked()
	self.creatorAvatar:change(self.cursorRaw)
end

function DeletePuzzlesSidebar:onMoved()
	self.creatorAvatar:setTarget(self.cursorRaw)
end
