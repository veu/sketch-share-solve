class("TutorialSidebar").extends(Sidebar)

function TutorialSidebar:init()
	TutorialSidebar.super.init(self)
end

function TutorialSidebar:enter(context, selected)
	local config = {
		menuTitle = "Solve tutorial",
		menuItems = {
			{
				text = "Show",
				exec = function()
					closeSidebar()
				end
			},
			{
				text = "Hint style: " .. NUM_STYLE_NAMES[context.settings.hintStyle],
				selected = selected == ACTION_ID_HINT_STYLE,
				img = createHintStylePreview(context.settings.hintStyle),
				exec = function ()
					self.onHintStyleNext()
				end,
				execLeft = function ()
					self.onHintStylePrevious()
				end,
				execRight = function ()
					self.onHintStyleNext()
				end
			}
		}
	}

	TutorialSidebar.super.enter(
		self,
		context,
		config
	)
end
