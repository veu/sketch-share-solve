function reverseNumbers(numbers)
	local length = #numbers
	local newNumbers = table.create(length, 0)
	for i = 1, #numbers do
		newNumbers[length - i + 1] = numbers[i]
	end
	return newNumbers
end

function numbersToPattern(numbers)
	local patterns = table.create(#numbers, 0)

	for i = 1, #numbers do
		patterns[i] = "()" .. string.rep("[^2]", numbers[i])
	end

	return "^[^1]-" .. table.concat(patterns, "[^1][^1]-") .. "[^1]*$"
end

function numbersToLineSolvedPattern(numbers)
	local patterns = table.create(#numbers, 0)

	for i = 1, #numbers do
		patterns[i] = "()" .. string.rep("1", numbers[i])
	end

	return "^[^1]-" .. table.concat(patterns, "[^1][^1]-") .. "[^1]*$"
end

function solutionColumnToString(puzzle, x, solution)
	local s = ""

	for y = 1, puzzle.height do
		local index = x - 1 + (y - 1) * puzzle.width + 1
		s = s .. solution[index]
	end

	return s
end

function solutionRowToString(puzzle, y, solution)
	return table.concat(solution, "", (y - 1) * puzzle.width + 1, y * puzzle.width)
end

function reverseIndexes(indexes, size)
	local length = #indexes
	local newIndexes = table.create(length, 0)
	for i = 1, #indexes do
		newIndexes[length - i + 1] = size - indexes[i] + 1
	end
	return newIndexes
end
