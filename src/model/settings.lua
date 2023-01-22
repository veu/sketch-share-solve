class("Settings").extends()

function Settings:init(settings)
	self.crankSpeed = settings.crankSpeed or 5
	self.fontType = settings.fontType or FONT_TYPE_THIN
	self.hintStyle = settings.hintStyle or NUM_STYLE_THIN
	self.music = settings.music or 6
	self.effects = settings.effects or 6
end

function Settings:save(context)
	context.save.settings = {
		crankSpeed = self.crankSpeed,
		fontType = self.fontType,
		hintStyle = self.hintStyle,
		music = self.music,
		effects = self.effects,
	}

	save(context)
end

Settings.load = function (context)
	return Settings(context.save.settings or {})
end

