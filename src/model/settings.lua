class("Settings").extends()

function Settings:init(settings)
	self.crankSpeed = settings.crankSpeed or 5
end

function Settings:save(context)
	context.save.settings = {
		crankSpeed = self.crankSpeed
	}

	save(context)
end

Settings.load = function (context)
	return Settings(context.save.settings or {})
end

