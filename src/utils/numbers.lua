function reverseNumbers(numbers)
	local newNumbers = {}
	for _, number in pairs(numbers) do
		table.insert(newNumbers, 1, number)
	end
	return newNumbers
end

function numbersToPattern(numbers)
	local r = "^[^#]-"

	for i, n in pairs(numbers) do
		r = i > 1 and r .. "[^#][^#]-()" or r .. "()"
		for _ = 1, n do
			r = r .. "[^x]"
		end
	end

	return r .. "[^#]*$"
end

function solutionColumnToString(level, x, solution, crossed)
	local s = ""

	for y = 1, level.height do
		local index = x - 1 + (y - 1) * level.width + 1
		s = s .. (
			solution[index] == 1 and "#" or
			crossed[index] == 1 and "x" or
			" "
		)
	end

	return s
end

function solutionRowToString(level, y, solution, crossed)
	local s = ""

	for x = 1, level.width do
		local index = x - 1 + (y - 1) * level.width + 1
		s = s .. (
			solution[index] == 1 and "#" or
			crossed[index] == 1 and "x" or
			" "
		)
	end

	return s
end


function reverseIndexes(indexes, size)
	local newIndexes = {}
	for _, index in pairs(indexes) do
		table.insert(newIndexes, 1, size - index + 1)
	end
	return newIndexes
end
