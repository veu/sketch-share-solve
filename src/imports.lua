import "CoreLibs/animation"
import "CoreLibs/frameTimer"
import "CoreLibs/graphics"
import "CoreLibs/keyboard"
import "CoreLibs/nineslice"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/string"
import "CoreLibs/timer"

gfx = playdate.graphics

import "constants"

import "input/default"
import "input/modal"
import "input/noop"

import "model/done-numbers"
import "model/done-numbers-disabled"
import "model/done-numbers-line"
import "model/numbers"
import "model/profile"
import "model/puzzle"
import "model/settings"

import "screen/screen"
import "screen/about"
import "screen/create-avatar"
import "screen/create-puzzle"
import "screen/play-puzzle"
import "screen/sketch-tutorial"
import "screen/solved-puzzle"
import "screen/solve-tutorial"
import "screen/title"

import "sidebar/sidebar"
import "sidebar/about"
import "sidebar/create-avatar"
import "sidebar/create-puzzle"
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
import "ui/creator"
import "ui/creator-avatar"
import "ui/cursor"
import "ui/dialog"
import "ui/frame"
import "ui/grid"
import "ui/grid-numbers"
import "ui/grid-numbers-bg"
import "ui/grid-solved"
import "ui/list"
import "ui/menu-border"
import "ui/modal"
import "ui/player-avatar"
import "ui/text-cursor"
import "ui/time"
import "ui/timer"
import "ui/title"
import "ui/tutorial-dialog"

import "utils/files"
import "utils/numbers"
import "utils/string"
import "utils/ui"

fontGrid = gfx.font.newFamily({
	[gfx.font.kVariantNormal] = "font/grid",
	[gfx.font.kVariantBold] = "font/grid-bold"
})
assert(fontGrid)
fontText = gfx.font.newFamily({
	[gfx.font.kVariantNormal] = "font/text",
	[gfx.font.kVariantBold] = "font/text",
	[gfx.font.kVariantItalic] = "font/text"
})
assert(fontText)
fontFormatted = gfx.font.newFamily({
	[gfx.font.kVariantNormal] = "font/text",
	[gfx.font.kVariantBold] = "font/text-bold",
	[gfx.font.kVariantItalic] = "font/text"
})
assert(fontFormatted)
imgAvatars, err = gfx.imagetable.new("img/avatars")
assert(imgAvatars, err)
imgGrid, err = gfx.imagetable.new("img/grid")
assert(imgGrid, err)
imgCursor, err = gfx.imagetable.new("img/cursor")
assert(imgCursor, err)
imgMode, err = gfx.imagetable.new("img/mode")
assert(imgMode, err)
imgPattern, err = gfx.imagetable.new("img/pattern")
assert(imgPattern, err)
imgBox, err = gfx.imagetable.new("img/box")
assert(imgBox, err)
imgDialog = gfx.nineSlice.new("img/dialog", 19, 9, 2, 2)
imgTitle = gfx.image.new("img/title")
assert(imgTitle, err)
imgMenuBorder = gfx.image.new("img/menu-border")
assert(imgMenuBorder, err)
imgRdk = gfx.image.new("img/rdk")
assert(imgRdk, err)
imgAbout = gfx.image.new("img/about")
assert(imgAbout, err)
