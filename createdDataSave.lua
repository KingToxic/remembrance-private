local ds = game:GetService("DataStoreService")
local ms = ds:GetDataStore("Main")

local rs = game:GetService("ReplicatedStorage")

local ds = rs:WaitForChild("DataSend")
local sd = rs:WaitForChild("SaveData")
local es = rs:WaitForChild("ErrorSend")

local ts = game:GetService("TeleportService")
local mapId = 101879233898642

local soundservice = game:GetService("SoundService")
soundservice.CharacterCreate:Play()


function dataStore(player,rep1,stringName,colors1,colors2,variantValue,stringLastName)
	local data = ms:GetAsync(player.UserId)
	
if data then
		local slots = data["perm"].Slots
		print(slots,data)
		if slots > 1 then
			for i = slots,1,-1 do
				if data["slots"][i]["PlayerName"] == "empty" then
					print("empty found")
					if data["slots"][i]["Status"] == "active" then
					print(i,data,slots)
					print("active slot")
					local combString = tostring(stringName.. stringLastName)
					data["slots"][i]["PlayerName"] = combString
					data["slots"][i]["Variant"] = variantValue
					data["slots"][i]["ColorWay"] = {tostring(colors1), tostring(colors2)}
					print(data)
						ms:SetAsync(player.UserId,data)
					end
				end
			end
	else
			if slots == 1 then
				local slotNum = 1
				local alive = slots[1].Status
				local slotsFid = data["slots"]
				local permFid = data["perm"]
				
				local slotData = slotsFid[slotNum]
				local raceValue = slotData.Race
				
				local guildName = permFid.Guild[1]
				local guildColor = permFid.Guild[2]
				local guildCombo = permFid.Guild[3]
				
				local rerollNum = permFid.Rerolls
				local rankInt = permFid.Rank
				local strengthInt = permFid.CharStats[1]
				local dexterityInt = permFid.CharStats[2]
				local arcaneInt = permFid.CharStats[3]
				local flexibilityInt = permFid.CharStats[4]
				local constitutionInt = permFid.CharStats[5]
				local luckInt = permFid.CharStats[6]
				local statPoints = permFid.CharStats[7]
				local dropChanceInt = permFid.Upgrades[1]
				local waterDecayInt = permFid.Upgrades[2]
				local foodDecayInt = permFid.Upgrades[3]
				local livesInt = permFid.Upgrades[4]
				local soulNumInt = permFid.Upgrades[5]
				
				
				if alive == false then

					local dataToSave = {
						["slots"] = {
							[slots] = {
								Status = "created",
								Race = raceValue,
								Lives = 4,
								Alignment = {rep1},
								Inventory = {equipped = {
													},
										unequipped = {
												}
											},
								Money = 0,
								PlayerName = stringName,
								ColorWay = {colors1,colors2},
								Level = {0, 0},
								Variant = variantValue,
								CharStats = {strengthInt,dexterityInt,arcaneInt,flexibilityInt,constitutionInt,luckInt,statPoints}
							}
						},
						["perm"] = {
							Upgrades = {dropChanceInt,waterDecayInt,foodDecayInt,livesInt,soulNumInt},
							Guild = {guildName,guildColor,guildCombo},
							Slots = slotNum,
							Rerolls = rerollNum,
							Rank = rankInt
						}
					}
					print(dataToSave)
				end
			end
		end
	else
		local dataToSave = {
			["slots"] = {
				[1] = {
					Status = "created",
					Race = "Skeleton",
					Lives = 3,
					Alignment = {rep1},
					Inventory = {equipped = {
								""
									},
						unequipped = {
							""
							
						}},
					Money = 0,
					PlayerName = stringName.. stringLastName,
					ColorWay = {tostring(colors1),tostring(colors2)},
					Level = {0, 0},
					Variant = variantValue,
					CharStats = {0,0,0,0,0,0,0}
				}
			},
			["perm"] = {
				Upgrades = {0,0,0,0,0},
				Guild = {"","",0},
				Slots = 1,
				Rerolls = 0,
				Rank = 0
			}
		}
		local success, err = pcall(function()
			--ms:SetAsync(player.UserId, dataToSave)
			print(dataToSave,"tried save")
		end)
	end
end

local function dataCatch(player)
	print(player)
	local rep1 = player:GetAttribute("Rep1")
	--local rep2 = player:GetAttribute("Rep2")
	local variantValue = player:GetAttribute("Variant")
	local colors1 = player:GetAttribute("ShoeColor")
	local colors2 = player:GetAttribute("LimbColor")
	local stringName = player:GetAttribute("stringName")
	local stringLastName = player:GetAttribute("stringLastName")
	if rep1 and variantValue and colors1 and colors2 and stringName and stringLastName then
		dataStore(player,rep1,stringName,colors1,colors2,variantValue,stringLastName)
		es:FireClient(player)
		
		ts:Teleport(mapId,player)
	else
		print(rep1,variantValue,colors1,colors2,stringName,stringLastName)
	end
end


sd.OnServerEvent:Connect(function(player)
	dataCatch(player)
end)
