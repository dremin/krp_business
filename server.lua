-- NOTE: Update Kashacters to rename owner column of businesses table
businesses = {}
ESX = nil
local hasSqlRun = false
local refundAmount = 0.8
local maxPerChar = 2

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Load items
AddEventHandler('onMySQLReady', function()
	loadBusinesses()
end)

-- extremely useful when restarting script mid-game
Citizen.CreateThread(function()
	Citizen.Wait(2000) -- hopefully enough for connection to the SQL server

	if not hasSqlRun then
		loadBusinesses()
	end
end)

-- load business data from database and store in cache
function loadBusinesses()
	MySQL.Async.fetchAll("SELECT b.id, b.label, b.defaultLabel, b.location, b.price, b.earnings, b.owner, b.lastPayout, concat(u.firstName, ' ', u.lastName) as ownerName, u.phone_number as phone FROM `businesses` as b left join `users` as u on b.owner = u.identifier", {}, function(result)
		businesses = {}
		for i = 1, #result do
			table.insert(businesses, {
				id = result[i].id,
				label = result[i].label,
				defaultLabel = result[i].defaultLabel,
				location = json.decode(result[i].location),
				price = result[i].price,
				earnings = result[i].earnings,
				owner = result[i].owner,
				lastPayout = result[i].lastPayout,
				ownerName = result[i].ownerName,
				phone = result[i].phone
			})
		end
		-- indicate that businesses table is ready to send to clients
		hasSqlRun = true
	end)
end

-- get businesses that havent paid out in at least a day, then give the owner money
function checkPayouts(d, h, m)
	print('krp_business: Checking payouts')
	MySQL.Async.fetchAll("SELECT id, label, earnings, owner FROM `businesses` where lastPayout <= timestamp(DATE_SUB(NOW(), INTERVAL 1 DAY)) and owner is not null and owner != ''", {}, function(payouts)
		for i = 1, #payouts do
			local identifier = payouts[i].owner
			local earnings = payouts[i].earnings
			local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
			
			-- if player is online, use ESX methods to give them money
			if xPlayer ~= nil then
				xPlayer.addAccountMoney('bank', earnings)
		
				TriggerClientEvent("esx:showNotification", xPlayer.source, "Your business, " .. payouts[i].label .. ", earned you $" .. payouts[i].earnings)
				print('krp_business: Gave online payout to ' .. identifier)
			else
				-- player is offline, give money via database
				MySQL.Async.fetchAll('SELECT bank FROM users WHERE identifier = @identifier', { ["@identifier"] = identifier }, function(result)
					if result[1]["bank"] ~= nil then
						MySQL.Async.execute("UPDATE users SET bank = @newBank WHERE identifier = @identifier",
							{
								["@identifier"] = identifier,
								["@newBank"] = result[1]["bank"] + earnings
							}, function(rowsChanged)
								if rowsChanged > 0 then
									print('krp_business: Gave offline payout to ' .. identifier)
								end
							end
						)
					else
						print('krp_business: Unable to give player ' .. identifier .. ' earnings because of a database issue')
					end
				end)
			end
			
			MySQL.Async.execute('update businesses set lastPayout = timestamp(now()) where id = @businessId',
	            {
	            	['@businessId'] = payouts[i].id
	            }
	        )
		end
	end)
end

-- called by clients to get/refresh business data
RegisterServerEvent('krp_business:getBusinesses')
AddEventHandler('krp_business:getBusinesses', function()
	local _source = source
	while not hasSqlRun do
		-- wait for initial data fetch to complete
		Citizen.Wait(2000)
	end
	
	TriggerClientEvent("krp_business:updateBusinesses", _source, businesses)
end)

RegisterServerEvent('krp_business:characterChanged')
AddEventHandler('krp_business:characterChanged', function(oldUserId, newUserId)
	for i = 1, #businesses do
		if businesses[i].owner == oldUserId then
			businesses[i].owner = newUserId
			TriggerClientEvent("krp_business:updateBusinesses", -1, businesses)
			break
		end
	end
end)

RegisterServerEvent('krp_business:buyBusiness')
AddEventHandler('krp_business:buyBusiness', function(business, name)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	
	-- check if player already has max businesses
	MySQL.Async.fetchAll('SELECT count(id) as numOwned FROM businesses WHERE owner = @identifier', { ["@identifier"] = xPlayer.identifier }, function(result)
		local isMaxOwned = false
		if result[1] ~= nil and result[1].numOwned ~= nil and result[1].numOwned ~= "" then
			if tonumber(result[1].numOwned) >= maxPerChar then
				isMaxOwned = true
				TriggerClientEvent("esx:showNotification", _source, "You must sell one of your businesses before buying another.")
			end
		end

		if not isMaxOwned then
			-- check if we can afford this business
			if xPlayer.getMoney() >= business.price then
				-- update db
				MySQL.Async.execute('update businesses set owner = @owner, label = @label where id = @businessId',
					{
						['@owner'] = xPlayer.identifier,
						['@label'] = name,
						['@businessId'] = business.id
					}, function(rowsChanged)
						if rowsChanged > 0 then
							-- charge and notify user
							xPlayer.removeMoney(business.price)
							TriggerClientEvent('esx:showNotification', _source, 'Congratulations! You now own this business.')
				
							for i = 1, #businesses do
								if businesses[i].id == business.id then
									MySQL.Async.fetchAll('SELECT firstname, lastname, phone_number FROM users WHERE identifier = @identifier', { ["@identifier"] = xPlayer.identifier }, function(result)
										if result[1] ~= nil then
											businesses[i].owner = xPlayer.identifier
											businesses[i].ownerName = result[1].firstname .. ' ' .. result[1].lastname
											businesses[i].phone = result[1].phone_number
											businesses[i].label = name

											-- tell all clients about the updated businesses table
											TriggerClientEvent("krp_business:updateBusinesses", -1, businesses)
										else
											print('krp_business: Unable to get player ' .. identifier .. ' phone number because of a database issue')
										end
									end)
									break
								end
							end
							
						else
							TriggerClientEvent("esx:showNotification", _source, "The realtor has died in a horrific fire.")
						end
				end)
			else
				-- sorry, not enough money
				local missingMoney = business.price - xPlayer.getMoney()
				TriggerClientEvent('esx:showNotification', _source, 'You need $' .. missingMoney .. ' more in order to afford this business.')
			end
		end
	end)
end)

RegisterServerEvent('krp_business:sellBusiness')
AddEventHandler('krp_business:sellBusiness', function(business)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	-- set refund to given percentage of purchase price, and truncate decimal to hundredths
	local refund = tonumber((math.floor(business.price * refundAmount * 100) / 100) + 0.01)
	
	MySQL.Async.execute("update businesses set owner = null, label = @defaultLabel where id = @businessId and owner = @oldOwner",
        {
        	['@businessId'] = business.id,
        	['@defaultLabel'] = business.defaultLabel,
        	['@oldOwner'] = xPlayer.identifier
        }, function(rowsChanged)
        	if rowsChanged > 0 then
	        	-- fund and notify user
				xPlayer.addMoney(refund)
			
				TriggerClientEvent("esx:showNotification", _source, "You no longer own this business and have been refunded a percentage of the purchase price.")
				
				-- update businesses in cache
			    for i = 1, #businesses do
				    if businesses[i].id == business.id then
					    businesses[i].owner = nil
					    businesses[i].ownerName = ""
					    businesses[i].phone = ""
					    businesses[i].label = businesses[i].defaultLabel
					    break
					end
				end
		
				-- tell all clients about the updated businesses table
				TriggerClientEvent("krp_business:updateBusinesses", -1, businesses)
			else
				print('krp_business: ' .. xPlayer.identifier .. ' attempted to sell a business they do not own')
				TriggerClientEvent("esx:showNotification", _source, "You didn't own this business.")
			end
    end)
end)

-- schedule cron job for running payouts
TriggerEvent('cron:runAt', 12, 0, checkPayouts)
TriggerEvent('cron:runAt', 0, 0, checkPayouts)