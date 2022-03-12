class("MenuBorder").extends(gfx.sprite)

function MenuBorder:init()
	MenuBorder.super.init(self, imgMenuBorder)

	self:setCenter(0, 0)
	self:setZIndex(Z_INDEX_MENU_BORDER)
end

function MenuBorder:enter()
	self:add()
end

function MenuBorder:leave()
	self:remove()
end
