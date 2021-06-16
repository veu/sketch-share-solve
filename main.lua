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
local screen = title
local context = {
	creator = nil,
	level = nil,
	player = nil,
	mode = nil,
	save = nil
}
local showCrank = true

creatorSelection.onSelected = function(selectedCreator)
	context.creator = selectedCreator
	creatorSelection:leave()
	gridList:enter(context)
	screen = gridList
end

gridCreate.onBackToList = function()
	gridCreate:leave()
	modeSelection:enter(context)
	screen = modeSelection
end

gridCreate.onTestAndSave = function ()
	gridCreate:leave()
	gridPlay:enter(context)
	screen = gridPlay
end

gridList.onSelectedLevel = function (level)
	context.level = Level(context.save.levels[context.creator][level])
	gridList:leave()
	gridPlay:enter(context)
	screen = gridPlay
end

gridPlay.onBackToList = function()
	gridPlay:leave()
	gridList:enter(context)
	screen = gridList
end

gridPlay.onEdit = function()
	gridPlay:leave()
	gridCreate:enter(context)
	screen = gridCreate
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
	gridPlay:leave()
	modeSelection:enter(context)
	screen = modeSelection
end

modeSelection.onSelected = function(selectedMode)
	context.mode = selectedMode
	modeSelection:leave()
	if context.mode == MODE_PLAY then
		creatorSelection:enter(context)
		screen = creatorSelection
	else
		context.level = Level.createEmpty(context.player)
		gridCreate:enter(context)
		screen = gridCreate
	end
end

title.onSelected = function(selectedAvatar)
	showCrank = false
	context.player = selectedAvatar
	title:leave()
	modeSelection:enter(context)
	screen = modeSelection
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
