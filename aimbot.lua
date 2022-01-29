local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local runService = game:GetService("RunService");
local userInputService = game:GetService("UserInputService");

local client = players.LocalPlayer;
local mouse = client:GetMouse();
local character = client.Character or client.CharacterAdded:Wait();
local humanoid = character:WaitForChild("Humanoid");
local humanoidRootPart = character:WaitForChild("HumanoidRootPart");

local qbAim = true; 

local function getDistanceFrom(player1, player2)
    if player1.Character and player2.Character then
        return (player1.Character.HumanoidRootPart.Position - player2.Character.HumanoidRootPart.Position).Magnitude;
    end;
    return 0;
end;

local function getDistanceFrom2(player1, player2)
    if player1.Character and player2.Character then
        print("yuh"..tostring(player1.Character), tostring(player2.Character))
        return (player1.Character.HumanoidRootPart.Position - player2.Character.HumanoidRootPart.Position).Magnitude;
    end;
    return 0;
end;

local function getClosestPlayers(player)
    local closestPlayers = {};
    for i,v in pairs(players:GetPlayers()) do
        if v ~= player then
            if v.Character then
                local distance = getDistanceFrom(player, v);
                table.insert(closestPlayers, v)
            end;
        end;
    end;
    return closestPlayers;
end

local function getUserBehindPlayer(player)
    local closestPlayers = getClosestPlayers(player)
    if closestPlayers then
        local closestPlayer = nil;
        local closestDistance = math.huge;
        for i,v in pairs(closestPlayers) do
            local dot = (humanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Unit:Dot(humanoidRootPart.CFrame.LookVector);
            print(dot, v)
            if dot > 0 and getDistanceFrom(player, v) < closestDistance and getDistanceFrom(player, v) < 30 then
                closestDistance = getDistanceFrom(player, v);
                closestPlayer = v;
            end;
        end;
        return closestPlayer;
    end;
    return nil;
end;

local function closestToMouse()
    local closestPlayer = nil; 
    local closestDistance = math.huge; 
    for _, player in ipairs(players:GetPlayers()) do
        if player == client then continue end;
        local char = player.Character;
        local hum2 = char:WaitForChild("Humanoid");
        local humanoidRootPart2 = char:WaitForChild("HumanoidRootPart");
        if char and hum2 and hum2.Health > 0 then
            if client.Team == player.Team then
                local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(humanoidRootPart2.Position);
                local check = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude

                if check < closestDistance then
                    closestDistance = check; 
                    closestPlayer = player; 
                end;
            end;
        end;
    end;
    return closestPlayer;
end;

local selectionPart = Instance.new("Part");
selectionPart.CanCollide = false;
selectionPart.Anchored = true;
selectionPart.Transparency = 0.75;
selectionPart.Size = Vector3.new(5, 5, 5);
selectionPart.Material = Enum.Material.Neon;
selectionPart.Color = Color3.new(1, 0, 0);

local selection = nil;
local selectionPart_transparency = selectionPart.Transparency;

runService.RenderStepped:Connect(function()
    local target = closestToMouse(); 
    --print(target)
    if target and qbAim then
        local char2 = target.Character;
        if char2 then
            local humanoidRootPart2 = char2:WaitForChild("HumanoidRootPart");
            if humanoidRootPart then
                selection = humanoidRootPart2;
            end;
        end;
    end;

    if selection and qbAim then
        if selection:IsA("Part") then
            selectionPart.Transparency = selectionPart_transparency;
            selectionPart.Parent = workspace;
            selectionPart.Color = Color3.new(1, 0, 0)
            for _ = 1, 10 do
                selectionPart.CFrame = selection.CFrame; 
            end;
        else
            selectionPart.Transparency = 1;
        end;
    else
        selectionPart.Transparency = 1;
    end;
end)

local function calculateY(target, dist)
    local function perfect()
        if not getUserBehindPlayer(target) then print(530) return dist / (530) end;
        local distance = getDistanceFrom2(target, getUserBehindPlayer(target));
        print((525 + (distance / 2)))
        return dist / (525 + (distance / 2));
    end;
    
    local z = perfect()
    print(z)
    return dist * z;
end;

local function broo(p9, p10)
    return math.asin(math.clamp(p9 * 28 / math.pow(p10, 2), -1, 1)) / 2;
end;

local function IDontCare(p12, p13)
    return 2 * p13 * math.sin((broo(p12, p13))) / 28 ;
end;

local function getInfo(character2)
    local hum2 = character2:WaitForChild("Humanoid");
    local head2 = character2:WaitForChild("Head");

    local newPos = character:WaitForChild("Head").Position;
    local dist = (newPos - head2.Position).Magnitude;
    local power = 95;

    local heyXD = head2.CFrame + hum2.MoveDirection * (hum2.WalkSpeed * (IDontCare(dist, power)) + 0.75);
    local offset = calculateY(players:GetPlayerFromCharacter(character2), (Vector3.new(heyXD.X, heyXD.Y, heyXD.Z) - newPos).Magnitude);
    print(tostring(Vector3.new(heyXD.X, offset + heyXD.Y, heyXD.Z)));
    return Vector3.new(heyXD.X, offset + heyXD.Y, heyXD.Z);
end;

local function throw()
    local target = closestToMouse(); 
    if target and target.Character then
        return getInfo(target.Character);
    end;
end;

local oldNamecall 
local practiceMode = game.PlaceId == 8206123457

if (not practiceMode) then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}

        if (tostring(self) == "RemoteEvent" or args[1] == "Clicked") then
            if (qbAim) then
                args[3] = throw() 
                args[4] = 95 

                return self.FireServer(self, unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end)
else
    -- sloppy copy paste
    local metatable = getrawmetatable(game)

	--// Custom functions aliases

	local setreadonly = setreadonly or set_readonly
	local make_writeable = make_writeable or function(t)
		setreadonly(t, false)
	end
	local make_readonly = make_readonly or function(t)
		setreadonly(t, true)
	end
	local detour_function = detour_function or replace_closure or hookfunction
	local setclipboard = setclipboard or set_clipboard or writeclipboard
	local get_namecall_method = get_namecall_method or getnamecallmethod
	local protect_function = protect_function or newcclosureyield or newcclosure or function(...)
		return ...
	end
	
	local Methods = {
		RemoteEvent = "FireServer",
		RemoteFunction = "InvokeServer"
	}
	
	for Class, Method in next, Methods do
		local original_function = Instance.new(Class)[Method] 
		local function new_function(self, ...)
			local args = {...}
			
			if typeof(self) == "Instance" and tostring(self) == "RemoteEvent" or args[1] == "Clicked" then
				if qbAim then
				    args[4] = 95
                    args[3] = throw()
					return original_function(self, unpack(args))
				end
			elseif tostring(self) == "RemoteEvent" or args[1] == "Clicked" then
				print(unpack(args))
			end
			
			return original_function(self, ...)
		end
		
		
		new_function = protect_function(new_function)
		original_function = detour_function(original_function, new_function)
		
	end
end


userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if (input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent) then
        qbAim = not qbAim;
    end;
end)


client.CharacterAdded:Connect(function(character3)
    character = character3;
    humanoid = character3:WaitForChild("Humanoid");
    humanoidRootPart = character3:WaitForChild("HumanoidRootPart");
end);
