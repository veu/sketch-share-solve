function escapeString(input)
	return string.gsub(input, "[*_]", "%0%0")
end

function unescapeString(input)
	return string.gsub(input, "([*_])%1", "%1")
end

function isOverMax(input)
	return
		gfx.getTextSize(input, fontTextThin) > MAX_NAME_WIDTH or
		gfx.getTextSize(input, fontTextBold) > MAX_NAME_WIDTH
end

function limitToMax(input)
	if isOverMax(input) then
		for i = #input, 1, -1 do
			if not isOverMax(input:sub(1, i)) then
				return input:sub(1, i)
			end
		end
	end

	return input
end
