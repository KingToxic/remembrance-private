local players = game:GetService("Players")
local dSS = game:GetService("DataStoreService")
local mS = dSS:GetDataStore("Main")
local SS = game:GetService("ServerStorage")
local Packet = require(game.ReplicatedStorage.Packet)
local DC = game:GetService("ReplicatedStorage").dataChange

local soundS = game:GetService("SoundService")
soundS["Rain Sound Effect"]:Play()


function UIUpdate(player,slotdata) --client first update
	local myPacket = Packet("MyTestPacket", Packet.Any)
	myPacket:FireClient(player,slotdata)
end

function DSUpdate(player,tb)
	if player and tb then
		mS:SetAsync(player.UserId,tb)
		local slotNum = tb["perm"]["Slots"]
		UIUpdate(player,tb["slots"][slotNum])
		setGameStats(player,tb["slots"][slotNum]["CharStats"])
	end
end

local sendDialogue = Packet("sendDialogue", Packet.Any)
local receiveDialogue = Packet("receiveDialogue", Packet.Any)

centaurDialogue = {}

strPathTb = {}

sendDialogue.OnServerEvent:Connect(function(player,dialoguetb)  --check if player in talkbox else send hide
	centaurDialogue[""] = {"Centaur","Take Apple", "End Dialogue", "Would you like an apple "..tostring(player.Name)..", they are very healthy for you..."}
	centaurDialogue["Y"] = {"Centaur","End Dialogue", "End Dialogue", "Here you go."}
	centaurDialogue["N"] = {"Centaur","End Dialogue", "End Dialogue", "Okay, suit yourself."}
	centaurDialogue["YN"] = {"Hide","Hide", "End Dialogue", "Okay, suit yourself."}
	centaurDialogue["NY"] = {"Hide","Hide", "End Dialogue", "Okay, suit yourself."}
	centaurDialogue["YY"] = {"Hide","Hide", "End Dialogue", "Okay, suit yourself."}
	centaurDialogue["NN"] = {"Hide","Hide", "End Dialogue", "Okay, suit yourself."}
	
	local npc = dialoguetb[1]
	if not npc then return end
	
	local path = dialoguetb[2]
	if not path then return end
	
	strPathTb[player.UserId] = ""
	local tblen = table.maxn(path)
	
	for tblen, choice in path do
		print(choice)
		if tblen == 1 then
			strPathTb[player.UserId] = strPathTb[player.UserId]..choice.Name
		else
			strPathTb[player.UserId] = strPathTb[player.UserId]..choice.Name
		end 
	end
	
	if tblen > 2 then
		strPathTb[player.UserId] = ""
	end
	
	if npc == "centaurTest" then
		local dialogue = centaurDialogue[strPathTb[player.UserId]]
		if not dialogue then return end
		
		receiveDialogue:FireClient(player,dialogue)
		print(dialogue,strPathTb)
	end
end)

local equipTool = Packet("equipToolPacket", Packet.Any)
local checkToolData = Packet("checkToolDataPacket", Packet.Any)
local sendToolData = Packet("sendToolDataPacket", Packet.Any)

itemTbDb = {
	["copperSword"] = "onehand",
	["rubyRing"] = "ring",
	["berserkHelm"] = "helm",
	["witchRobe"] = "chest",
	["witchHat"] = "helm",
	["goldNecklace"] = "neck",
	["Spell"] = "onehand",
	["Bow"] = "onehand",
	["TripleShot"] = "onehand",
	["PoisonShot"] = "onehand",
}

checkToolData.OnServerEvent:Connect(function(player,toolname)
	local char = player.Character
	print(char)
	if not char then return end
	local tool = itemTbDb[tostring(toolname)]
	print(tool,toolname)
	
	if tool == "ring" or tool == "helm" or tool == "chest" or tool == "neck" then
		local info = {slot = tool,toolN = toolname,statTb = {"tbd","tbr","tbz"}}
		sendToolData:FireClient(player,info)
		print(info)
	end
	
	if tool == "onehand" then
		if toolname == "copperSword" then
			local info  = {slot = tool,toolN = toolname,range = 7.5, damage = 9, parryWindow = 0.6, atkSpeed = "366 ms", scaling = {"+0.2 / STR","+0.5 / DEX"}, type = "slash"}
			sendToolData:FireClient(player,info)
			print("data fired")
			print(info)
		end
		if toolname == "Spell" then
			local info  = {slot = tool,toolN = toolname,range = 12, damage = 8, parryWindow = 0.6, atkSpeed = "366 ms", scaling = {"+0.5 / ARC",""}, type = "magic"}
			sendToolData:FireClient(player,info)
			print(info)
		end
		if toolname == "Bow" then
			local info  = {slot = tool,toolN = toolname,range = 28, damage = 6, parryWindow = 0.4, atkSpeed = "366 ms", scaling = {"+0.5 / DEX",""}, type = "slash"}
			sendToolData:FireClient(player,info)
			print(info)
		end
	end
end)

equipTool.OnServerEvent:Connect(function(player, str)
	local char = player.Character
	if not char then return end
	
	local db = mS:GetAsync(player.UserId)
	if not db then return end
	
	local tool = player.Backpack:FindFirstChild(str)
	
	local slotNum = db["perm"]["Slots"]
	local unequip = db["slots"][slotNum]["Inventory"]["unequipped"]
	local equip = db["slots"][slotNum]["Inventory"]["equipped"]
	
	local location = itemTbDb[str]
	if not location then
		print(tool)
	end
	
	if location == "ring" then
		local tool = player.Character:FindFirstChild(str)
	end
	
	if not tool then 
		if char:FindFirstChild(str) then
			char:FindFirstChild(str).Parent = player.Backpack
		end
	end
	if char:FindFirstChildOfClass("Tool") then
		char:FindFirstChildOfClass("Tool").Parent = player.Backpack
	else
		if tool then
			equip[str] = location
			print(equip)
			local Inventory = Packet("Inventory", Packet.Any)
			Inventory:FireClient(player,{location,str})
			tool.Parent = char
		end
	end
end)


local addAtt = Packet("addAtt", Packet.Any)

statTable = {"strength", "dexterity", "arcane", "flexibility", "constitution", "luck", "total"} --duped


addAtt.OnServerEvent:Connect(function(player,...)
	local saveTb = mS:GetAsync(player.UserId)
	if not saveTb then return end
	
	local slotNum = saveTb["perm"]["Slots"]
	
	local strength = saveTb["slots"][slotNum]["CharStats"][1]
	local dexterity = saveTb["slots"][slotNum]["CharStats"][2]
	local arcane = saveTb["slots"][slotNum]["CharStats"][3]
	local flexibility = saveTb["slots"][slotNum]["CharStats"][4]
	local constitution = saveTb["slots"][slotNum]["CharStats"][5]
	local luck = saveTb["slots"][slotNum]["CharStats"][6]
	
	local totalPoints = saveTb["slots"][slotNum]["CharStats"][7]
	if saveTb["slots"][slotNum]["CharStats"][7] == 0 then return end
	
	
	if ... == "strength" then
		saveTb["slots"][slotNum]["CharStats"][1] = saveTb["slots"][slotNum]["CharStats"][1] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	elseif ... == "dexterity" then
		saveTb["slots"][slotNum]["CharStats"][2] = saveTb["slots"][slotNum]["CharStats"][2] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	elseif ... == "arcane" then
		saveTb["slots"][slotNum]["CharStats"][3] = saveTb["slots"][slotNum]["CharStats"][3] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	elseif ... == "flexibility" then
		saveTb["slots"][slotNum]["CharStats"][4] = saveTb["slots"][slotNum]["CharStats"][4] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	elseif ... == "constitution" then
		saveTb["slots"][slotNum]["CharStats"][5] = saveTb["slots"][slotNum]["CharStats"][5] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	elseif ... == "luck" then
		saveTb["slots"][slotNum]["CharStats"][6] = saveTb["slots"][slotNum]["CharStats"][6] + 1
		saveTb["slots"][slotNum]["CharStats"][7] = saveTb["slots"][slotNum]["CharStats"][7] - 1
	end	
	
	print(player,...,totalPoints,saveTb)
	
	DSUpdate(player,saveTb)
end)


DC.OnServerEvent:Connect(function(player,target,new)  -- dogshit unsecure
	if not player then
		return
	else
		local success, dbreturn = pcall(function()
			return 	mS:GetAsync(player.UserId)
		end)
		local newint = tonumber(new)
		local strtar = tostring(target)
		local slotNumber = dbreturn["perm"]["Slots"]
		local slotNum = nil
		
		for i = slotNumber,1,-1 do
			if dbreturn["Slots"][slotNumber]["Status"] == "active" then
				slotNum = slotNumber
			end
		end
		if not slotNum then return end
		
		if target == "xp" then
			if dbreturn["slots"][slotNum]["Level"][2] < 5 then
				local level = dbreturn["slots"][slotNum]["Level"][2] + 1
				local xpTb = {10,500,850,1250,300,300}
				print(level)
				local xpLim = xpTb[level]
				local xp = dbreturn["slots"][slotNum]["Level"][1]
				print(xpLim)
				if xpLim > xp then
					dbreturn["slots"][slotNum]["Level"][1] = dbreturn["slots"][slotNum]["Level"][1] + newint
					DSUpdate(player,dbreturn)
				else
					dbreturn["slots"][slotNum]["Level"][2] = dbreturn["slots"][slotNum]["Level"][2] + 1
					dbreturn["slots"][slotNum]["CharStats"][7] = dbreturn["slots"][slotNum]["CharStats"][7] + 2
					dbreturn["slots"][slotNum]["Level"][1] = 0
					DSUpdate(player,dbreturn)
				end
			end
			--dbreturn["slots"][slotNum]["Level"][1] = dbreturn["slots"][slotNum]["Level"][1] + newint
			
			--mS:SetAsync(player.UserId, dbreturn)
			--print(dbreturn)
		end
	end
end)

local function isDescendantOfShoes(part)
	while part do
		if part:IsA("Model") and (part.Name == "rightshoe" or part.Name == "leftshoe") then
			return true -- The part belongs to the shoe, so skip it
		end
		part = part.Parent
	end
	return false
end

local function color(model, player, color)
	local color3
	if typeof(color) == "Color3" then
		color3 = color
	elseif type(color) == "string" then
		local r, g, b = color:match("([%-?%d.]+)%s*,%s*([%-?%d.]+)%s*,%s*([%-?%d.]+)")
		if r and g and b then
			r, g, b = tonumber(r), tonumber(g), tonumber(b)

			r = math.clamp(r, 0, 1)
			g = math.clamp(g, 0, 1)
			b = math.clamp(b, 0, 1)

			color3 = Color3.fromRGB(r * 255, g * 255, b * 255)
		else
			print(color)
			return
		end
	else
		print("Invalid")
		return
	end

	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("MeshPart") and not isDescendantOfShoes(v) and v.Name ~= "Robe" then  --smartbone testing
			v.Color = color3
		end
	end
end

local function colorShoes(model, player, shoecolor)
	local color3
	if typeof(shoecolor) == "Color3" then
		color3 = shoecolor
	elseif type(shoecolor) == "string" then
		local r, g, b = shoecolor:match("([%-?%d.]+)%s*,%s*([%-?%d.]+)%s*,%s*([%-?%d.]+)")
		if r and g and b then
			r, g, b = tonumber(r), tonumber(g), tonumber(b)
]
			r = math.clamp(r, 0, 1)
			g = math.clamp(g, 0, 1)
			b = math.clamp(b, 0, 1)

			color3 = Color3.fromRGB(r * 255, g * 255, b * 255)
		end
	end

	if color3 then
		for _, v in pairs(model:GetDescendants()) do
			if v:IsA("Model") and (v.Name == "rightshoe" or v.Name == "leftshoe") then
				for _, part in pairs(v:GetDescendants()) do
					if part:IsA("MeshPart") then
						part.Color = color3
					end
				end
			end
		end
	end
end

function teleportAway(player)
	print(player)
end

function modelSpawn(player,character,raceStr)
	local raceModelsFolder = SS.DB:WaitForChild("Race")
	local raceModel = raceModelsFolder:WaitForChild(raceStr)
	local newModel = raceModel:Clone()
	newModel.Name = player.Name
	player.Character = newModel
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	local plrRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
	if rootPart and plrRoot then
		rootPart.CFrame = plrRoot.CFrame
	end
	newModel.Parent = workspace
	player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(-200, 43.021, -1902)
	local nameTag = player.Character:FindFirstChild("skull"):FindFirstChild("NameTag")
	nameTag.PlayerToHideFrom = player	
end



local sb = game:GetService("ReplicatedStorage").SprintBool

defSpeedTb = {}
defStamTb = {}

hpOffsetTb = {}

function setGameStats(player,charStatArray)
	--print(statTable[4],charStatArray[4]) --works
	local hum = player.Character:FindFirstChild("Humanoid")
	if not hum then return end
	
	hum.WalkSpeed = hum.WalkSpeed + (charStatArray[4] * 2) --flexibility
	
	defSpeedTb[player.UserId] = hum.WalkSpeed + (charStatArray[4] * 2)
	--defSpeedTb[player.UserId] = hum.WalkSpeed 
	
	hum.JumpPower = hum.JumpPower + (charStatArray[4] * 2) --flexibility

	player:SetAttribute("ManaPool", 100 + (charStatArray[3] * 25)) --arcane 
	
	player:GetAttributeChangedSignal("ManaPool"):Connect(function()
		local newMana = player:GetAttribute("ManaPool")
		local Packet = require(game.ReplicatedStorage.Packet) --client first update
		local myPacket = Packet("manaPacket", Packet.NumberS8)
		myPacket:FireClient(player,newMana)
	end)
	
	player:SetAttribute("StaminaPool",100 + (charStatArray[2] * 10)) --dexterity
	
	defStamTb[player.UserId] = 100 + (charStatArray[2] * 10) 
	
	player:GetAttributeChangedSignal("StaminaPool"):Connect(function()
		local newStam = player:GetAttribute("StaminaPool")
		local Packet = require(game.ReplicatedStorage.Packet) --client first update
		local myPacket = Packet("stamPacket", Packet.NumberS8)
		myPacket:FireClient(player,newStam)
	end)
	
	local hpOffset = hpOffsetTb[player.UserId]
	if not hpOffset then 
		hpOffsetTb[player.UserId] = 0
	end

	hum.MaxHealth = 100 + (charStatArray[5] * 15) + hpOffsetTb[player.UserId]-- const
	hum.Health = hum.MaxHealth -- gratitude reset
	
	print(player,charStatArray,"setgameStats")
end

varTb = {"bulky","scholar","miner","social","nimble"}

jumpTotalTb = {}

function setVarStats(player,...)
	if not player.Character then return end
	
	local var = varTb[...]
	local permWepScalingPacket = Packet("permWepPacket", Packet.Any)  --optimize
	
	if var == "bulky" then
		hpOffsetTb[player.UserId] = 15
		permWepScalingPacket:Fire(player,"strength")
	end
	if var == "scholar" then
		--xp gain
		permWepScalingPacket:Fire(player,"wisdom")
	end
	if var == "miner" then
		if not player.Character:FindFirstChild("skull") then return end
		
		
		local skull = player.Character:FindFirstChild("skull")
		local minerHelm = SS:WaitForChild("minerhelm",1)
		
		local weld = skull:FindFirstChild("WeldConstraint")
		
		minerHelm:Clone()

		minerHelm.Parent = player.Character
		
		weld = Instance.new("WeldConstraint")
		minerHelm.CFrame = CFrame.new(skull.CFrame.X,skull.CFrame.Y+0.5,skull.CFrame.Z)
		weld.Part0 = skull
		weld.Part1 = minerHelm
		weld.Parent = minerHelm
	end
	if var == "social" then
		
	end
	if var == "nimble" then
		jumpTotalTb[player.UserId] = 2
		
	end
end


sbt = {}

regenTb = {}

function stamRegen(player)
	local maxStam = defStamTb[player.UserId]
	local regen = 5
	local regenSpeed = 1  --wait
	
	print(regenTb,sbt)
	
	if regenTb[player.UserId] == true then
		print("attempt to regen")
		return
	else
	
	while sbt[player.UserId] == false or sbt[player.UserId] == nil do
		local oldstam = player:GetAttribute("StaminaPool")
		print(oldstam,maxStam,sbt,regen)
			if maxStam >= (oldstam + regen) then
				regenTb[player.UserId] = true
			print("set att")
			player:SetAttribute("StaminaPool", oldstam + regen)
			wait(regenSpeed)
			else
				regenTb[player.UserId] = false
				print("broke from top")
				break
			end
		end
	end
end

function sprintBool(player,key)
	local oldspeed = defSpeedTb[player.UserId]
	if not oldspeed then return end
	if not player then return end
	if not key then return end
	
	--if not playerTrailBool then return end
	
	if key == "down" then
		sbt[player.UserId] = true
	end
	
	if key == "up" then
		sbt[player.UserId] = false
	end
	
	print(key,sbt)
	
	while sbt[player.UserId] == true do
		
		local oldstam = player:GetAttribute("StaminaPool")
		if oldstam < 10 then
			player.Character.Humanoid.WalkSpeed = oldspeed
			sbt[player.UserId] = false
			regenTb[player.UserId] = false
			stamRegen(player)
			print("break")
			break
		else
			player.Character.Humanoid.WalkSpeed = oldspeed + 10
			
			local newstam = oldstam - 10
		player:SetAttribute("StaminaPool", newstam)
		print("stamreduced",oldstam,newstam)
			wait(1)
		end
	if sbt[player.UserId] == false then
			player.Character.Humanoid.WalkSpeed = oldspeed
		stamRegen(player)
		end
	end
end

sb.OnServerEvent:Connect(sprintBool)

local function dataSpawn(player,character)
	
	local success, dbreturn = pcall(function()
		return 	mS:GetAsync(player.UserId)
	end)
	if success then --put checks status,lives,rank
		local data = dbreturn["slots"]
		local permdata = dbreturn["perm"]
		if permdata["Slots"] == 1 then
			local slot = data[1]
			local raceStr = tostring(slot["Race"])
			local raceModelsFolder = SS.DB:WaitForChild("Race")
			local raceModel = raceModelsFolder:WaitForChild(raceStr)
			local limbcolor = tostring(slot.ColorWay[2])
			local shoecolor = tostring(slot.ColorWay[1])
			if raceModel then
				modelSpawn(player,character,raceStr)
				setGameStats(player,slot["CharStats"])
				UIUpdate(player,slot)
				setVarStats(player,slot["Variant"])
					color(player.Character,player.Character,limbcolor)
					colorShoes(player.Character,player.Character,limbcolor)
		end
		elseif permdata["Slots"] > 1 then
			print(data,dbreturn)
			local slotNumber = permdata["Slots"]
			for i = slotNumber,1,-1 do
				if data[i]["Status"] == "active" then
					print(i, "active slot")
					local slot = data[i]
					local raceStr = tostring(slot["Race"])
					local raceModelsFolder = SS.DB:WaitForChild("Race")
					local raceModel = raceModelsFolder:WaitForChild(raceStr)
					local limbcolor = tostring(slot.ColorWay[2])
					local shoecolor = tostring(slot.ColorWay[1])
					if raceModel then
						modelSpawn(player,character,raceStr)
						setGameStats(player,slot["CharStats"])
						UIUpdate(player,slot)
						setVarStats(player,slot["Variant"])
						color(player.Character,player.Character,limbcolor)
						colorShoes(player.Character,player.Character,limbcolor)
			end
		end
	end
		end
	end
end



local jumpCheck = Packet("doubleJumpGet", Packet.Any)
local jumpCd = 0.5

jumpCheck.OnServerEvent:Connect(function(player,...)
	print(...)
	local hum = player.Character:FindFirstChild("Humanoid")
	if not hum then return end

	local state = hum:GetState()
	if not state then return end

	if not jumpTotalTb[player.UserId] then
		jumpTotalTb[player.UserId] = 1
	end
	
	local jumpTotal = jumpTotalTb[player.UserId]
	
	if hum:GetState("Landing") then
		jumpTotal = jumpTotalTb[player.UserId]
	end
	
	if jumpTotal > 0 then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
		jumpTotal = jumpTotal - 1
	end
	print(jumpTotal)
end)


function oldmodel(player) --oldaf
	local dbreturn = ""
	local data = dbreturn["slots"]

	local Race = SS.DB:WaitForChild("Race")

	local raceStr = tostring(data[1].Race)
	local raceModel = Race:FindFirstChild(raceStr)

	local limbcolor = tostring(data[1].ColorWay[2])
	local shoecolor = tostring(data[1].ColorWay[1])

	if raceModel then
		local character = raceModel:Clone()

		local Anims = raceModel:FindFirstChild("Anims")

		local walkAnim = Anims:FindFirstChild("walk")
		local runAnim = Anims:FindFirstChild("run")
		character.Name = player.Name
		player.Character = character
		local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
		local plrRoot = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
		character.Animate.walk.WalkAnim.AnimationId = walkAnim.AnimationId
		character.Animate.run.RunAnim.AnimationId = runAnim.AnimationId
		if data[1].Race == "Skeleton" and data[1].Variant then
			color(character, player.Name, limbcolor)
			colorShoes(character, player.Name, shoecolor)
		end
		if rootPart and plrRoot then
			rootPart.CFrame = plrRoot.CFrame
		end
		character.Parent = workspace
	end
	--player.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(-40, 30.062, -124)
end

local loadTable = {}

local function playerAdded(player)
	player.CharacterAdded:Connect(function(character)
		if loadTable[player.UserId] == nil then
			dataSpawn(player, player.Character)
			loadTable[player.UserId] = true -- Mark the player as loaded
		end
	end)
end

local diedPacket = Packet("died", Packet.Any)
diedPacket.OnServerEvent:Connect(function(player)
	loadTable[player.UserId] = nil
	playerAdded(player)
end)


players.PlayerAdded:Connect(function(player)
	playerAdded(player)
end)


--game.Players.PlayerRemoving:Connect(playerLeft)

