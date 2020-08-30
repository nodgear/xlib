function AwUI:CreateFont(sName, iSize, sFont, iWeight, tMerge)
    local tbl = {
		font = sFont or "Montserrat Regular",
		size = (iSize + 2) or 16,
		weight = iWeight or 500,
		extended = true
	}

	if (tMerge) then
		table.Merge(tbl, tMerge)
	end

	surface.CreateFont(sName, tbl)
end


--- Draw a poly arc
-- @number x xPos
-- @number y yPos
-- @number p InitialPoint
-- @number rad Radius
-- @color color Color
-- @number seg Segments (points)
-- @realm client
function AwUI:DrawArc(x, y, ang, p, rad, color, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {x = x, y = y})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
	end

	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

--- Returns a table with a poly arc for later cache
-- @number x xPos
-- @number y yPos
-- @number p InitialPoint
-- @number rad Radius
-- @color color Color
-- @number seg Segments (points)
-- @realm client
-- @treturn table circle
function AwUI:CalculateArc(x, y, ang, p, rad, seg)
	seg = seg or 80
	ang = (-ang) + 180
	local circle = {}

	table.insert(circle, {x = x, y = y})
	for i = 0, seg do
		local a = math.rad((i / seg) * -p + ang)
		table.insert(circle, {x = x + math.sin(a) * rad, y = y + math.cos(a) * rad})
	end

	return circle
end

--- Draws a previously cached arc
-- @string Variable with the circle table
-- @color color Color
-- @realm client
function AwUI:DrawCachedArc(circle, color)
	surface.SetDrawColor(color)
	draw.NoTexture()
	surface.DrawPoly(circle)
end

function AwUI:DrawShadowText(text, font, x, y, col, xAlign, yAlign, amt, shadow)
    for i = 1, amt do
      draw.SimpleText(text, font, x + i, y + i, Color(0, 0, 0, i * (shadow or 50)), xAlign, yAlign)
    end
  
    draw.SimpleText(text, font, x, y, col, xAlign, yAlign)
end

function AwUI:DrawRoundedBoxEx(radius, x, y, w, h, col, tl, tr, bl, br)
	--Validate input
	x = math.floor(x)
	y = math.floor(y)
	w = math.floor(w)
	h = math.floor(h)
	radius = math.Clamp(math.floor(radius), 0, math.min(h/2, w/2))

	if (radius == 0) then
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, w, h)

		return
	end

	--Draw all rects required
	surface.SetDrawColor(col)
	surface.DrawRect(x+radius, y, w-radius*2, radius)
	surface.DrawRect(x, y+radius, w, h-radius*2)
	surface.DrawRect(x+radius, y+h-radius, w-radius*2, radius)

	--Draw the four corner arcs
	if(tl) then
		AwUI:DrawArc(x+radius, y+radius, 270, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y, radius, radius)
	end

	if(tr) then
		AwUI:DrawArc(x+w-radius, y+radius, 0, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y, radius, radius)
	end

	if(bl) then
		AwUI:DrawArc(x+radius, y+h-radius, 180, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x, y+h-radius, radius, radius)
	end

	if(br) then
		AwUI:DrawArc(x+w-radius, y+h-radius, 90, 90, radius, col, radius)
	else
		surface.SetDrawColor(col)
		surface.DrawRect(x+w-radius, y+h-radius, radius, radius)
	end
end

function AwUI:DrawRoundedBox(radius, x, y, w, h, col)
	AwUI:DrawRoundedBoxEx(radius, x, y, w, h, col, true, true, true, true)
end

local matLoading = Material("xenin/loading.png", "smooth")

function AwUI:DrawLoadingCircle(x, y, size, col)
  surface.SetMaterial(matLoading)
  surface.SetDrawColor(col or ColorAlpha(XeninUI.Theme.Accent, 100))
  AwUI:DrawRotatedTexture(x, y, size, size, ((ct or CurTime()) % 360) * -100)
end

function AwUI:DrawRotatedTexture( x, y, w, h, angle, cx, cy )
	cx,cy = cx or w/2,cy or w/2
	if( cx == w/2 and cy == w/2 ) then
		surface.DrawTexturedRectRotated( x, y, w, h, angle )
	else	
		local vec = Vector( w/2-cx, cy-h/2, 0 )
		vec:Rotate( Angle(180, angle, -180) )
		surface.DrawTexturedRectRotated( x-vec.x, y+vec.y, w, h, angle )
	end
end