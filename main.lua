import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui/crankIndicator"
import "CoreLibs/ui/gridview"

import "constants"
import "input"
import "levels"
import "utils"
import "model/level"
import "model/numbers"
import "screen/screen"
import "screen/creator-selection"
import "screen/grid-create"
import "screen/grid-list"
import "screen/grid-play"
import "screen/mode-selection"
import "screen/title"
import "ui/board"
import "ui/board-numbers"
import "ui/cursor"
import "ui/list"
import "ui/sidebar"
import "ui/title"
import "utils/ui"

local gfx <const> = playdate.graphics

fontGrid = gfx.font.new("font/grid")
assert(fontGrid)
fontText = gfx.font.new("font/text")
assert(fontText)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)

local creatorSelection = CreatorSelection()
local gridCreate = GridCreate()
local gridList = GridList()
local gridPlay = GridPlay()
local modeSelection = ModeSelection()
local title = TitleScreen()
local context = {
	creator = nil,
	level = nil,
	player = nil,
	mode = nil,
	save = nil
}
local showCrank = true

local screen = title
function switchToScreen(newScreen)
	screen:leave()
	newScreen:enter(context)
	screen = newScreen
end

creatorSelection.onBackToModeSelection = function()
	switchToScreen(modeSelection)
end

creatorSelection.onSelected = function(selectedCreator)
	context.creator = selectedCreator
	switchToScreen(gridList)
end

gridCreate.onBackToList = function()
	switchToScreen(modeSelection)
end

gridCreate.onTestAndSave = function ()
	switchToScreen(gridPlay)
end

gridList.onBackToCreatorSelection = function()
	switchToScreen(creatorSelection)
end

gridList.onSelectedLevel = function (level)
	context.level = Level(context.save.levels[context.creator][level])
	switchToScreen(gridPlay)
end

gridPlay.onBackToList = function()
	switchToScreen(gridList)
end

gridPlay.onEdit = function()
	switchToScreen(gridCreate)
end

gridPlay.onSave = function()
	if context.save.levels[context.player] then
		table.insert(context.save.levels[context.player], context.level.level)
	else
		context.save.levels[context.player] = {
			context.level.level
		}
	end
	playdate.datastore.write(context.save)
	switchToScreen(modeSelection)
end

modeSelection.onBackToTitle = function()
	switchToScreen(title)
end

modeSelection.onSelected = function(selectedMode)
	context.mode = selectedMode
	if context.mode == MODE_PLAY then
		switchToScreen(creatorSelection)
	else
		context.level = Level.createEmpty(context.player)
		switchToScreen(gridCreate)
	end
end

title.onSelected = function(selectedAvatar)
	showCrank = false
	context.player = selectedAvatar
	switchToScreen(modeSelection)
end

function playdate.crankDocked()
	screen:crankDocked()
end

function playdate.crankUndocked()
	screen:crankUndocked()
end

function playdate.cranked(change, acceleratedChange)
	screen:cranked(change, acceleratedChange)
end

function playdate.AButtonDown()
	screen:AButtonDown()
end

function playdate.BButtonDown()
	screen:BButtonDown()
end

context.save = playdate.datastore.read() or DEFAULT_SAVE

playdate.ui.crankIndicator:start()
screen:enter()

function playdate.update()
	screen:update()

	gfx.sprite.update()
	if showCrank and playdate.isCrankDocked() then
		playdate.ui.crankIndicator:update()
	end
	--playdate.drawFPS(0,0)
	playdate.timer.updateTimers()
end
