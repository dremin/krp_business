ESX = nil
local businesses = {}
local blips = {}
local visibleBusinesses = {}
local enteredMarker = false
local enteredBusiness = nil
local PlayerData = {}
local drawDistance = 20.0
local markerSize = {x = 1.25, y = 1.25, z = 1.25}
local markerColor = {r = 0, g = 128, b = 255}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj)
			ESX = obj
			PlayerData = ESX.GetPlayerData()
		end)
		Citizen.Wait(0)
	end
	
	-- initial data fetch
	TriggerServerEvent("krp_business:getBusinesses")
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
	PlayerData = xPlayer
end)

-- Display text, marker, blip
Citizen.CreateThread(function()
    while true do
		local coords = GetEntityCoords(PlayerPedId())
		visibleBusinesses = {}
		
		for i = 1, #businesses do
			
			business = businesses[i]
			
			if GetDistanceBetweenCoords(business.location.x, business.location.y, business.location.z, coords) < drawDistance then
				table.insert(visibleBusinesses, business)
			end
				
			-- draw blip once
			if blips[i] == nil then
				local blip = AddBlipForCoord(business.location.x, business.location.y, business.location.z)
				SetBlipSprite(blip, 475)
				SetBlipScale(blip, 1.0)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(business.label)
				EndTextCommandSetBlipName(blip)
				blips[i] = blip
			end
			
		end

		Citizen.Wait(500)
		
	end
end)

-- Display text, marker, blip
Citizen.CreateThread(function()
    while true do
		
		for i = 1, #visibleBusinesses do
			
			business = visibleBusinesses[i]
			
			-- draw text
			Draw3DText(business.location.x, business.location.y, business.location.z +1.0  -1.400, "" .. business.label, 4, 0.14, 0.14)
				
			if business.owner ~= "" and business.owner ~= nil then
				Draw3DText(business.location.x, business.location.y, business.location.z +1.0  -1.700, "Owner: " .. business.ownerName, 4, 0.08, 0.08)
				Draw3DText(business.location.x, business.location.y, business.location.z +1.0  -1.850, "Phone: " .. business.phone, 4, 0.08, 0.08)
			else
				Draw3DText(business.location.x, business.location.y, business.location.z +1.0  -1.700, "Price: $" .. business.price, 4, 0.08, 0.08)
				Draw3DText(business.location.x, business.location.y, business.location.z +1.0  -1.850, "Earnings: $" .. business.earnings .. " per day", 4, 0.08, 0.08)
			end
			
			-- draw marker if owner or unowned
			if (ESX ~= nil and business.owner == PlayerData.identifier) or business.owner == nil or business.owner == "" then
				DrawMarker(1, business.location.x, business.location.y, business.location.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, markerSize.x, markerSize.y, markerSize.z, markerColor.r, markerColor.g, markerColor.b, 100, false, true, 2, false, false, false, false)
			end
			
		end

		Citizen.Wait(0)
		
	end
end)

-- Check if player is in marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local isInMarker = false
		local business = nil

		if #visibleBusinesses > 0 then
			local coords = GetEntityCoords(PlayerPedId())

			-- show marker when close and business owned by player or not owned at all
			for i = 1, #visibleBusinesses do
				if(GetDistanceBetweenCoords(coords, visibleBusinesses[i].location.x, visibleBusinesses[i].location.y, visibleBusinesses[i].location.z, true) < markerSize.x) and ((ESX ~= nil and visibleBusinesses[i].owner == PlayerData.identifier) or visibleBusinesses[i].owner == nil or visibleBusinesses[i].owner == "") then
					isInMarker = true
					business = visibleBusinesses[i]
				end
			end
		end
		
		-- only change enteredMarker value when leave/exit rather than every frame
		if isInMarker and not enteredMarker then
			enteredMarker = true
			enteredBusiness = business
		elseif isInMarker then
			enteredBusiness = business
		end
		if not isInMarker and enteredMarker then
			enteredMarker = false
			enteredBusiness = nil
		elseif not isInMarker then
			enteredBusiness = nil
		end
	end
end)

-- Check for key press
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if enteredMarker and enteredBusiness ~= nil then
			local owner = false
			
			if ESX ~= nil and enteredBusiness.owner == PlayerData.identifier then
				owner = true
			end

			SetTextComponentFormat('STRING')
			
			if owner then
				AddTextComponentString('Press ~INPUT_CONTEXT~ to sell the business.')
			else
				AddTextComponentString('Press ~INPUT_CONTEXT~ to purchase the business.')
			end
			
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then

				-- execute server event to purchase or sell
				if owner then
					TriggerServerEvent("krp_business:sellBusiness", enteredBusiness)
				else
					-- get custom name input
					DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", enteredBusiness.defaultLabel, "", "", "", 30)
						while (UpdateOnscreenKeyboard() == 0) do
							DisableAllControlActions(0)
							Wait(0)
						end
						if (GetOnscreenKeyboardResult()) then
							local result = GetOnscreenKeyboardResult()
							if result == "" then
								TriggerEvent("esx:showNotification", "Business purchase cancelled. The realtor is not pleased.")
							else
								-- do the purchase
								TriggerServerEvent("krp_business:buyBusiness", enteredBusiness, result)
							end
						end
				end
				
			end

		else
			Citizen.Wait(500)
		end
	end
end)

-- Get data updates from server
RegisterNetEvent('krp_business:updateBusinesses')
AddEventHandler('krp_business:updateBusinesses', function(data)
	businesses = data
end)


-- Helper functions
function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov   
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(250, 250, 250, 255)
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end