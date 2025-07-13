local rs = game:GetService("ReplicatedStorage")
local playButton = rs:WaitForChild("PlayButton")

local DS = game:GetService("DataStoreService")
local Main = DS:GetDataStore("Main")
local RunService = game:GetService("RunService")

local TS = game:GetService("TeleportService")

local Packet = require(game:GetService("ReplicatedStorage").Packet)



local characterCreationID = 71642590509880

local mapId = 101879233898642

function createGUIdata(player,data)
	print("lmaoaoa")
end

function dataCheck(player)
	
	if Main:GetAsync(player.UserId) then
		local data = Main:GetAsync(player.UserId)
		print(data)
		print(data["perm"])
		if data["perm"].Slots then
			local slotNum = data["perm"].Slots
			print(slotNum)
		end
		TS:Teleport(mapId,player)
		
		--createGUIdata(player,data) --TODO
	else
		TS:Teleport(characterCreationID,player)
	end
end


playButton.OnServerEvent:Connect(dataCheck)

local sendSlot = Packet("sendSlot", Packet.Any)
local addSlot = Packet("addSlot", Packet.Any)

game:GetService("Players").PlayerAdded:Connect(function(player)
	if Main:GetAsync(player.UserId) then
		local data = Main:GetAsync(player.UserId)
		--print(data)
		print(data["perm"].Slots)
		if data["perm"].Slots then
			local slotNum = data["perm"].Slots
			local activeSlot = nil
			for i = slotNum,1,-1 do
				sendSlot:FireClient(player,{i,data["slots"][i]})
				if data["slots"][i]["Status"] == "active" then
					data["slots"][i]["Status"] = "created"
				end
				Main:SetAsync(player.UserId,data)
			end
					
			end
				
		end
	end)
		--TS:Teleport(mapId,player)

	--createGUIdata(player,data) --TODO
	
--TS:Teleport(characterCreationID,player)

local function slotRefresh(player)
	if Main:GetAsync(player.UserId) then
		local data = Main:GetAsync(player.UserId)
		--print(data)
		print(data["perm"].Slots)
		if data["perm"].Slots then
			local slotNum = data["perm"].Slots
			local activeSlot = nil
			for i = slotNum,1,-1 do
				sendSlot:FireClient(player,{i,data["slots"][i]})
				if data["slots"][i]["Status"] == "active" then
					activeSlot = i
					print(activeSlot)
				end
			end
		end
	end
end



addSlot.OnServerEvent:Connect(function(player)
	if player ~= "MassiveMurdererz" then return end
	print("sent") 
		print("worked")
	local data = Main:GetAsync(player.UserId)
	data["perm"].Slots = data["perm"].Slots + 1
		print(data)
		local newSlot = {
					Status = "empty",
					Race = "Skeleton",
					Lives = 3,
					Alignment = {""},
					Inventory = {equipped = {
						""
					},
						unequipped = {
							""

						}},
					Money = 0,
					PlayerName = "empty".. "",
					ColorWay = {tostring(""),tostring("")},
					Level = {0, 0},
					Variant = 0,
					CharStats = {0,0,0,0,0,0,0}
				}
		print(newSlot)
	table.insert(data["slots"], newSlot)
	Main:SetAsync(player.UserId,data)
	slotRefresh(player)
end)

local delSlot = Packet("delSlot", Packet.Any)
delSlot.OnServerEvent:Connect(function(player,data)
	local slotNum = tonumber(data[1])
	local charName = tostring(data[2])
	print(slotNum,charName)
	local dataTb = Main:GetAsync(player.UserId)
	if not dataTb then return end
	
	print(dataTb)
	
	if not dataTb["slots"][slotNum] then return end
	if not dataTb["slots"][slotNum]["PlayerName"] then return end
	
	if dataTb["slots"][slotNum]["PlayerName"] == charName then
		dataTb["slots"][slotNum]["Status"] = "empty"
		dataTb["slots"][slotNum]["PlayerName"] = "empty"
		Main:SetAsync(player.UserId,dataTb)
	end
end)

local playButton = Packet("playButton", Packet.Any)
local ts = game:GetService("TeleportService")

local function teleport(player,slotNum)
	local savedata = Main:GetAsync(player.UserId)
	if not savedata then return end
	
	local status = savedata["slots"][slotNum]["Status"]
	local pname = savedata["slots"][slotNum]["PlayerName"]
	
	if pname ~= "empty" then
		ts:Teleport(101879233898642,player)
	elseif pname == "empty" then
		ts:Teleport(71642590509880,player)
	else
		print(status,pname)
	end
end

playButton.OnServerEvent:Connect(function(player,data)
	print("played",player,data)
	
	local dataTb = Main:GetAsync(player.UserId)
	if not dataTb then return end
	
	local slotNum = tonumber(data)
	
	if not dataTb["slots"][slotNum] then return end
	
	print(dataTb["slots"][slotNum])
	if dataTb["slots"][slotNum]["Status"] == "empty" then
		dataTb["slots"][slotNum]["Status"] = "active"
	elseif dataTb["slots"][slotNum]["Status"] == "created" then
		dataTb["slots"][slotNum]["Status"] = "active"
	elseif dataTb["slots"][slotNum]["Status"] == "active" then
		dataTb["slots"][slotNum]["Status"] = "active"
	elseif dataTb["slots"][slotNum]["Status"] == "creating" then
		dataTb["slots"][slotNum]["Status"] = "active"
	end
	
	
	Main:SetAsync(player.UserId,dataTb)
	teleport(player,slotNum)
end)