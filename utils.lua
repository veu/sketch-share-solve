local geo <const> = playdate.geometry

utils = {}

local savedDeps = {}

function utils.ifChanged(ctx, fun, deps)
	local saved = savedDeps[fun] or {}

	for i, dep in pairs(deps) do
		if dep ~= saved[i] then
			savedDeps[fun] = deps
			return fun(ctx, deps)
		end
	end
end
