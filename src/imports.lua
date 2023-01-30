import "CoreLibs/animation"
import "CoreLibs/frameTimer"
import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/nineslice"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"
import "CoreLibs/ui"

gfx = playdate.graphics

import "constants"

import "input/default"
import "input/modal"
import "input/noop"
import "input/undo"

import "model/done-numbers"
import "model/numbers"
import "model/profile"
import "model/puzzle"
import "model/settings"

import "screen/screen"
import "screen/about"
import "screen/create-avatar"
import "screen/create-puzzle"
import "screen/play-puzzle"
import "screen/select-creator"
import "screen/select-puzzle"
import "screen/sketch-tutorial"
import "screen/solved-puzzle"
import "screen/solve-tutorial"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/about"
import "sidebar/change-avatar"
import "sidebar/create-avatar"
import "sidebar/create-puzzle"
import "sidebar/delete-puzzles"
import "sidebar/name-puzzle"
import "sidebar/options"
import "sidebar/play-puzzle"
import "sidebar/select-avatar"
import "sidebar/select-creator"
import "sidebar/select-mode"
import "sidebar/select-player"
import "sidebar/select-puzzle"
import "sidebar/select-tutorial"
import "sidebar/settings"
import "sidebar/share"
import "sidebar/test-puzzle"
import "sidebar/title"
import "sidebar/tutorial"

import "ui/about"
import "ui/collection"
import "ui/creator"
import "ui/creator-avatar"
import "ui/cursor"
import "ui/dialog"
import "ui/frame"
import "ui/grid"
import "ui/grid-numbers"
import "ui/grid-numbers-bg"
import "ui/grid-numbers-left"
import "ui/grid-numbers-top"
import "ui/grid-solved"
import "ui/list"
import "ui/menu-border"
import "ui/modal"
import "ui/player-avatar"
import "ui/puzzle-preview"
import "ui/text-cursor"
import "ui/time"
import "ui/timer"
import "ui/title"
import "ui/tutorial-dialog"

import "utils/files"
import "utils/numbers"
import "utils/string"
import "utils/ui"

fontTextThin = gfx.font.new("font/text-thin")
fontTextBold = gfx.font.new("font/text-bold")
assert(fontTextThin)
assert(fontTextBold)
fontText = fontTextThin
fontTime = gfx.font.new("font/time")
assert(fontTime)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)
nilAvatar = saveAvatar(imgAvatars:getImage(AVATAR_ID_NIL))
imgGrid, err = gfx.imagetable.new("img/grid")
assert(imgGrid, err)
imgCursor, err = gfx.imagetable.new("img/cursor")
assert(imgCursor, err)
imgMode, err = gfx.imagetable.new("img/mode")
assert(imgMode, err)
imgBox, err = gfx.imagetable.new("img/box")
assert(imgBox, err)
imgSidebar, err = gfx.imagetable.new("img/sidebar")
assert(imgSidebar, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)
imgTitle = gfx.image.new("img/title")
assert(imgTitle, err)
imgMenuBorder = gfx.image.new("img/menu-border")
assert(imgMenuBorder, err)
imgRdk = gfx.image.new("img/rdk")
assert(imgRdk, err)
imgAbout = gfx.image.new("img/about")
assert(imgAbout, err)
imgPreview = gfx.imagetable.new("img/preview")
assert(imgPreview, err)

snd1 = {}
snd2 = {}
sndChannel = playdate.sound.channel.new()

local SOUNDS = {"back", "click", "cross", "erase", "scroll", "scrollEnd", "scrollFast", "sketch"}
for i, name in ipairs(SOUNDS) do
	local sound1, err = playdate.sound.sampleplayer.new("sound/" .. name)
	assert(sound1, err)
	snd1[name] = sound1
	sndChannel:addSource(sound1)
	local sound2, err = playdate.sound.sampleplayer.new("sound/" .. name)
	assert(sound2, err)
	snd2[name] = sound2
	sndChannel:addSource(sound2)
end

music = {}
musicChannel = playdate.sound.channel.new()

MUSIC_ENABLED = true
local track, err = playdate.sound.fileplayer.new("music/dialog", 1)
if track then
	music = track
	musicChannel:addSource(music)
	music:setStopOnUnderrun(false)
else
	MUSIC_ENABLED = false
end
