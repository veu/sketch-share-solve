local gfx <const> = playdate.graphics

function drawPaddedRect(x, y, w, h)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- padding
	gfx.setColor(gfx.kColorBlack)
	gfx.setDitherPattern(0.5)
	gfx.fillRect(x + 2, y + 2, w - 4, h - 4)
  gfx.setColor(gfx.kColorBlack)
	gfx.drawLine(x + 23, y + 2, x + 23, y + h - 2)
	gfx.drawLine(x + 2, y + h - 3, x + w - 2, y + h - 3)
end

function drawStripedRect(x, y, w, h)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- stripes
	gfx.setColor(gfx.kColorBlack)
	gfx.setDitherPattern(0.8, gfx.image.kDitherTypeDiagonalLine)
	gfx.fillRect(x + 2, y + 2, w - 4, h - 4)
end

function drawRightTextRect(x, y, w, h, text)
	-- outline
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, w, h)
	-- text
	gfx.setFont(fontText)
	local width = gfx.getTextSize(text)
	gfx.drawText(text, x + w - width - 5, y + 6)
end

function drawAvatar(x, y, id)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(x, y, 26, 26)
	gfx.drawRect(x + 2, y + 2, 22, 22)
	imgAvatars:getImage(id):drawScaled(x + 3, y + 3, 2)
end

function drawMenu(x, y, items, selected)
	for i = 1, rawlen(items) do
		gfx.pushContext()
		gfx.setDrawOffset(x + 4, y + 24 * (i - 1) + 4)
		do
			-- checkbox
			gfx.setColor(gfx.kColorBlack)
			gfx.fillRect(1, 3, 17, 17)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(2, 4, 15, 15)

			-- checkmark
			if selected == i then
				gfx.setFont(fontGrid)
				gfx.drawText("o", 2, 4)
			end

			-- text
			gfx.setFont(fontText)
			gfx.setColor(gfx.kColorWhite)
			local width = gfx.getTextSize(items[i].text)
			gfx.fillRect(23, 3, width + 4, 18)
			gfx.setColor(gfx.kColorBlack)
			gfx.drawText(items[i].text, 25, 5)
		end
	end
end
