class("Settings").extends()

function Settings:init(settings)
	self.crankSpeed = settings.crankSpeed or 5
	self.hintStyle = settings.hintStyle or NUM_STYLE_THIN
end

function Settings:save(context)
	context.save.settings = {
		crankSpeed = self.crankSpeed,
		hintStyle = self.hintStyle,
	}

	save(context)
end

Settings.load = function (context)
	return Settings(context.save.settings or {})
end

