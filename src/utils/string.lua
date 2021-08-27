function escapeString(input)
	return string.gsub(input, "[*_]", "%0%0")
end

function unescapeString(input)
	return string.gsub(input, "([*_])%1", "%1")
end
