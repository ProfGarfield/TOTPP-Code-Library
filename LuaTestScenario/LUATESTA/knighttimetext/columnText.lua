--[[
columnText.lua
v1.0
by Knighttime
]]

local CHAR_PIXEL_WIDTH = {
	[32]  =  5, --  	space
	[33]  =  6,	-- !
	[34]  =  6,	-- "
	[35]  = 10,	-- #
	[36]  = 10,	-- $
	[37]  = 16,	-- %
	[38]  = 12,	-- &	needs to be escaped with a second & in order to print
	[39]  =  3,	-- '
	[40]  =  6,	-- (
	[41]  =  6,	-- )
	[42]  =  7,	-- *
	[43]  = 11,	-- +
	[44]  =  5,	-- ,
	[45]  =  6,	-- -
	[46]  =  5,	-- .
	[47]  =  5,	-- /
	[48]  = 10,	-- 0
	[49]  =  9,	-- 1
	[50]  = 10,	-- 2
	[51]  = 10,	-- 3
	[52]  = 10,	-- 4
	[53]  = 10,	-- 5
	[54]  = 10,	-- 6
	[55]  = 10,	-- 7
	[56]  = 10,	-- 8
	[57]  = 10,	-- 9
	[58]  =  5,	-- :
	[59]  =  5,	-- ;
	[60]  = 11,	-- <
	[61]  = 11,	-- =
	[62]  = 11,	-- >
	[63]  = 10,	-- ?
	[64]  = 18,	-- @
	[65]  = 11,	-- A
	[66]  = 12,	-- B
	[67]  = 13,	-- C
	[68]  = 13,	-- D
	[69]  = 12,	-- E
	[70]  = 11,	-- F
	[71]  = 14,	-- G
	[72]  = 13,	-- H
	[73]  =  4,	-- I
	[74]  =  9,	-- J
	[75]  = 12,	-- K
	[76]  = 10,	-- L
	[77]  = 15,	-- M
	[78]  = 13,	-- N
	[79]  = 14,	-- O
	[80]  = 12,	-- P
	[81]  = 14,	-- Q
	[82]  = 13,	-- R
	[83]  = 12,	-- S
	[84]  = 12,	-- T
	[85]  = 13,	-- U
	[86]  = 11,	-- V
	[87]  = 17,	-- W
	[88]  = 11,	-- X
	[89]  = 12,	-- Y
	[90]  = 11,	-- Z
	[91]  =  5,	-- [
	[92]  =  5,	-- \
	[93]  =  5,	-- ]
	[94]  =  7,	-- ^
	[95]  =  0,	-- _	underscore does not print
	[96]  =  6,	-- `
	[97]  = 10,	-- a
	[98]  = 10,	-- b
	[99]  =  9,	-- c
	[100] = 10,	-- d
	[101] = 10,	-- e
	[102] =  5,	-- f
	[103] = 10,	-- g
	[104] = 10,	-- h
	[105] =  4,	-- i
	[106] =  4,	-- j
	[107] =  9,	-- k
	[108] =  4,	-- l
	[109] = 14,	-- m
	[110] = 10,	-- n
	[111] = 10,	-- o
	[112] = 10,	-- p
	[113] = 10,	-- q
	[114] =  6,	-- r
	[115] =  9,	-- s
	[116] =  5,	-- t
	[117] = 10,	-- u
	[118] =  9,	-- v
	[119] = 13,	-- w
	[120] =  8,	-- x
	[121] =  9,	-- y
	[122] =  8,	-- z
	[123] =  6,	-- {
	[124] =  6,	-- |
	[125] =  6,	-- }
	[126] = 11,	-- ~
--	[127] = ,	-- DEL
	[128] = 10,	-- €
--	[129] = ,	-- 
	[130] =  4,	-- ‚
	[131] = 10,	-- ƒ
	[132] =  7,	-- „
	[133] = 18,	-- …
	[134] = 10,	-- †
	[135] = 10,	-- ‡
	[136] =  6,	-- ˆ
	[137] = 17,	-- ‰
	[138] = 12,	-- Š
	[139] =  6,	-- ‹
	[140] = 18,	-- Œ
--	[141] = ,	-- 
	[142] = 11,	-- Ž
--	[143] = ,	-- 
--	[144] = ,	-- 
	[145] =  4,	-- ‘
	[146] =  4,	-- ’
	[147] =  7,	-- “
	[148] =  7,	-- ”
	[149] =  6,	-- •
	[150] = 10,	-- –
	[151] = 18,	-- —
	[152] =  5,	-- ˜
	[153] = 18,	-- ™
	[154] =  9,	-- š
	[155] =  6,	-- ›
	[156] = 17,	-- œ
--	[157] = ,	-- 
	[158] =  8,	-- ž
	[159] = 12,	-- Ÿ
	[160] =  5,	--  	non-breaking space
	[161] =  6,	-- ¡
	[162] = 10,	-- ¢
	[163] = 10,	-- £
	[164] = 10,	-- ¤
	[165] = 10,	-- ¥
	[166] =  6,	-- ¦
	[167] = 10,	-- §
	[168] =  6,	-- ¨
	[169] = 13,	-- ©
	[170] =  6,	-- ª
	[171] = 10,	-- «
	[172] = 11,	-- ¬
	[173] =  6,	-- ­
	[174] = 13,	-- ®
	[175] = 10,	-- ¯
	[176] =  7,	-- °
	[177] = 10,	-- ±
	[178] =  6,	-- ²
	[179] =  6,	-- ³
	[180] =  6,	-- ´
	[181] = 10,	-- µ
	[182] = 10,	-- ¶
	[183] =  6,	-- ·
	[184] =  6,	-- ¸
	[185] =  6,	-- ¹
	[186] =  7,	-- º
	[187] = 10,	-- »
	[188] = 15,	-- ¼
	[189] = 15,	-- ½
	[190] = 15,	-- ¾
	[191] = 11,	-- ¿
	[192] = 12,	-- À
	[193] = 12,	-- Á
	[194] = 12,	-- Â
	[195] = 12,	-- Ã
	[196] = 12,	-- Ä
	[197] = 12,	-- Å
	[198] = 18,	-- Æ
	[199] = 13,	-- Ç
	[200] = 12,	-- È
	[201] = 12,	-- É
	[202] = 12,	-- Ê
	[203] = 12,	-- Ë
	[204] =  5,	-- Ì
	[205] =  5,	-- Í
	[206] =  5,	-- Î
	[207] =  5,	-- Ï
	[208] = 13,	-- Ð
	[209] = 13,	-- Ñ
	[210] = 14,	-- Ò
	[211] = 14,	-- Ó
	[212] = 14,	-- Ô
	[213] = 14,	-- Õ
	[214] = 14,	-- Ö
	[215] = 11,	-- ×
	[216] = 14,	-- Ø
	[217] = 13,	-- Ù
	[218] = 13,	-- Ú
	[219] = 13,	-- Û
	[220] = 13,	-- Ü
	[221] = 12,	-- Ý
	[222] = 12,	-- Þ
	[223] = 11,	-- ß
	[224] =  6,	-- à
	[225] =  6,	-- á
	[226] =  6,	-- â
	[227] =  6,	-- ã
	[228] =  6,	-- ä
	[229] =  6,	-- å
	[230] = 16,	-- æ
	[231] =  9,	-- ç
	[232] = 10,	-- è
	[233] = 10,	-- é
	[234] = 10,	-- ê
	[235] = 10,	-- ë
	[236] =  5,	-- ì
	[237] =  5,	-- í
	[238] =  5,	-- î
	[239] =  5,	-- ï
	[240] = 10,	-- ð
	[241] = 10,	-- ñ
	[242] = 10,	-- ò
	[243] = 10,	-- ó
	[244] = 10,	-- ô
	[245] = 10,	-- õ
	[246] = 10,	-- ö
	[247] = 10,	-- ÷
	[248] = 10,	-- ø
	[249] = 10,	-- ù
	[250] = 10,	-- ú
	[251] = 10,	-- û
	[252] = 10,	-- ü
	[253] =  9,	-- ý
	[254] = 10,	-- þ
	[255] =  9,	-- ÿ
 }

local LINE_DELIMITER = "\n^"

local function round (decimal) --> integer
	return math.floor(decimal + 0.5)
end

local function convertTableToColumnText (columnTable, dataTable, borderWidth) --> string
	local messageText = ""
	if borderWidth == nil or borderWidth < 1 then
		borderWidth = 1
	end
	local columnCharPixelWidth = { }
	for columnNumber, columnData in ipairs(columnTable) do
		columnCharPixelWidth[columnNumber] = 0
		for _, data in ipairs(dataTable) do
			local pixelWidth = 0
			local stringData = tostring(data[columnData.column])
			if data[columnData.column] == nil then
				stringData = ""
			end
			for i = 1, #stringData do
				charPixels = CHAR_PIXEL_WIDTH[string.byte(stringData, i)]
				if charPixels == nil then
					print("WARNING: columnText.lua found no pixel length for character " .. tostring(string.byte(stringData, i)))
					charPixels = 0
				end
				pixelWidth = pixelWidth + charPixels
			end
			if pixelWidth > columnCharPixelWidth[columnNumber] then
				columnCharPixelWidth[columnNumber] = pixelWidth
			end
		end
	end
	for _, data in ipairs(dataTable) do
		messageText = messageText .. LINE_DELIMITER
		local pixelDifferenceThisLine = 0
		for columnNumber, columnData in ipairs(columnTable) do
			local pixelWidth = 0
			local stringData = tostring(data[columnData.column])
			if data[columnData.column] == nil then
				stringData = ""
			end
			for i = 1, #stringData do
				charPixels = CHAR_PIXEL_WIDTH[string.byte(stringData, i)]
				if charPixels == nil then
					charPixels = 0
				end
				pixelWidth = pixelWidth + charPixels
			end
			local pixelsNeeded = columnCharPixelWidth[columnNumber] - pixelWidth
			local spacesNeeded = round((pixelsNeeded + pixelDifferenceThisLine) / CHAR_PIXEL_WIDTH[32])
			pixelDifferenceThisLine = (pixelsNeeded + pixelDifferenceThisLine) - (spacesNeeded * CHAR_PIXEL_WIDTH[32])
			local columnBorderWidth = borderWidth
			if columnNumber == 1 then
				columnBorderWidth = 0
			end
			if columnData.align == "right" then
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. string.rep(" ", spacesNeeded) .. stringData
			elseif columnData.align == "center" then
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. string.rep(" ", round(spacesNeeded / 2)) .. stringData .. string.rep(" ", spacesNeeded - round(spacesNeeded / 2))
			else	-- default is left align
				messageText = messageText .. string.rep(" ", columnBorderWidth) .. stringData .. string.rep(" ", spacesNeeded)
			end
		end
	end
	return messageText
end

return {
	convertTableToColumnText = convertTableToColumnText,
}
