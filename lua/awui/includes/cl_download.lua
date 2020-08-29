AwUI.CachedIcons = AwUI.CachedIcons or {}

if (!file.IsDir("awesome/icons", "DATA")) then
  file.CreateDir("awesome/icons")
end


local function DownloadImage(tbl)
	local p = AwUI.Promises.new()

	if (!isstring(tbl.id)) then
		return p:reject("ID invalid")
	end

	local id = tbl.id
	local idLower = id:lower()
	local url = tbl.url or "https://i.imgur.com"
	local type = tbl.type or "png"

	if (AwUI.CachedIcons[id] and AwUI.CachedIcons[id] != "Loading") then
		return p:resolve(AwUI.CachedIcons[id])
	end

	local read = file.Read("awesome/icons/" .. idLower .. "." .. type)
	if (read) then
		AwUI.CachedIcons[id] = Material("../data/awesome/icons/" .. idLower .. ".png", "smooth")

		return p:resolve(AwUI.CachedIcons[id])
	end

	http.Fetch(url .. "/" .. id .. "." .. type, function(body)
		local str = "awesome/icons/" .. idLower .. "." .. type
		file.Write(str, body)

		AwUI.CachedIcons[id] = Material("../data/" .. str, "smooth")

		p:resolve(AwUI.CachedIcons[id])
	end, function(err)
		p:reject(err)
	end)

	return p
end

function AwUI:DownloadIcon(pnl, tbl, pnlVar)
	if (!tbl) then return end

	local p = AwUI.Promises.new()

	if (isstring(tbl)) then
		tbl = { { id = tbl } }
	end

	local i = 1
	local function AsyncDownload()
		if (!tbl[i]) then p:reject() end

		pnl[pnlVar or "Icon"] = "Loading"
		DownloadImage(tbl[i]):next(function(result)
			p:resolve(result):next(function()
				pnl[pnlVar or "Icon"] = result
			end, function(err)
				ErrorNoHalt(err)
			end)
		end, function(err)
			i = i + 1

			ErrorNoHalt(err)

			AsyncDownload()
		end)
	end

	AsyncDownload()

	return p
end

function AwUI:DrawIcon(x, y, w, h, pnl, col, loadCol, var)
	col = col or color_white
	loadCol = loadCol or color_red
	var = var or "Icon"

	if (pnl[var] and type(pnl[var]) == "IMaterial") then
		surface.SetMaterial(pnl[var])
		surface.SetDrawColor(col)
		surface.DrawTexturedRect(x, y, w, h)
	elseif (pnl[var] != nil) then
		AwUI:DrawLoadingCircle(h, h, h, loadCol)
  end
end

-- Can be used, but I recommend using :DownloadIcon one as it's more customisable
-- This is preserved for old use
function AwUI:GetIcon(id)
	local _type = type(id)
	if (_type == "IMaterial") then
		return id
	end

	if (self.CachedIcons[id]) then
		return self.CachedIcons[id]
	end

	local read = file.Read("awesome/icons/" .. id:lower() .. ".png")
	if (read) then
		self.CachedIcons[id] = Material("../data/awesome/icons/" .. id:lower() .. ".png", "smooth")
	else
		self.CachedIcons[id] = "Loading"
	end

	http.Fetch("https://i.imgur.com/" .. id .. ".png", function(body, len)
		local str = "awesome/icons/" .. id:lower() .. ".png"
		file.Write(str, body)

		self.CachedIcons[id] = Material("../data/" .. str, "smooth")
	end)
end
