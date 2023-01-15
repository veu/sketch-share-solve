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
				selected = selected == ACTION_ID_CRANK_SPEED,
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
			{
				text = "Font type: " .. FONT_TYPE_NAMES[context.settings.fontType],
				selected = selected == ACTION_ID_FONT_TYPE,
				exec = function ()
					self.onFontTypeToggle()
				end,
				execLeft = function ()
					self.onFontTypeToggle()
				end,
				execRight = function ()
					self.onFontTypeToggle()
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
			},
			{
				text = "Sound effects: " .. AUDIO_LEVEL_NAMES[context.settings.soundEffects],
				selected = selected == ACTION_ID_SOUND_EFFECTS,
				exec = function ()
					self.onSoundEffectsUp()
				end,
				execLeft = function ()
					self.onSoundEffectsDown()
				end,
				execRight = function ()
					self.onSoundEffectsUp()
				end
			},
			{
				text = "Delete puzzles",
				selected = selected == ACTION_ID_DELETE_PUZZLES,
				exec = function ()
					self.onDeletePuzzles()
				end,
			}
		}
	}

	SettingsSidebar.super.enter(self, context, config)
end
