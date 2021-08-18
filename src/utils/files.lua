function getFileNameForPlayer(name)
	name = name:lower()
	name = name:gsub("[^a-z0-9 -]", "")
	name = name:gsub("[ -]+", "-")
	name = name:gsub("^-", "")
	if name:len() > 0 then
		return name
	end

	return "default"
end
