spawn(function()
	function prints(mess)
		appendfile("TDS_AutoStrat/LastPrintLog.txt",tostring(mess).."\n")
		print(tostring(mess))
	end
    local RS = game:WaitForChild('ReplicatedStorage')
    local RSRF = RS:WaitForChild("RemoteFunction")
    local RSRE = RS:WaitForChild("RemoteEvent")
    function EquipTroop(troop)
        if game.PlaceId ~= 5591597781 then
        local args = {
            [1] = "Inventory",
            [2] = "Execute",
            [3] = "Troops",
            [4] = "Add",
            [5] = {
                ["Name"] = tostring(troop)
            }
        }
        game.ReplicatedStorage.RemoteEvent:FireServer(unpack(args))
        end
    end
    function UnEquip()
        for TowerName, Tower in next, game.ReplicatedStorage.RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops") do
            if (Tower.Equipped) then
                local args = {
                    [1] = "Inventory",
                    [2] = "Execute",
                    [3] = "Troops",
                    [4] = "Remove",
                    [5] = {
                        ["Name"] = TowerName
                    }
                }
                game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
            end;
        end;
    end
    if game.PlaceId == 5591597781 then
    getgenv().map = game:GetService("ReplicatedStorage").State.Map.Value
    else
        spawn(function()
			getgenv().timer = 0
			while wait(1) do
				getgenv().timer = getgenv().timer + 1
			end
		end)
        getgenv().BreakEvery = false
        getgenv().repeating = true
		if not getgenv().MultiStratType then
			getgenv().MultiStratType = "Survival"
		end
		spawn(function()
			spawn(function()
				getgenv().timer = 0
				while wait(1) do
					getgenv().timer = getgenv().timer + 1
				end
			end)
			getgenv().repeating = true
			while wait(1) do
				if getgenv().repeating then
					getgenv().repeating = false
					local jc = 0
					for _, Elevators in pairs(game:GetService('Workspace').Elevators:GetChildren()) do
						local mp = Elevators.State.Map.Title
						local plrs = Elevators.State.Players
						local rq = require(Elevators.Settings).Type
						if getgenv().Maps[mp.Value] ~= nil and rq == getgenv().MultiStratType then
							if (plrs.Value <= 0) then
								jc = jc + 1
								prints("Join attempt...")
								getgenv().status = "Joining..."
								RSRF:InvokeServer("Elevators","Enter",Elevators)
								UnEquip()
								for i,v in next, getgenv().Maps[mp.Value] do
									EquipTroop(v)
								end
								prints("Joined elavator...")
								getgenv().status = "Joined"
								while wait() do
									getgenv().status = "Joined ("..Elevators.State.Timer.Value.."s)"
									if Elevators.State.Timer.Value == 0 then
										local s = true
										for c=1,100 do
										if (plrs.Value > 1) then
											prints("Someone joined, leaving elevator...")
											getgenv().status = "Someone joined..."
											RSRF:InvokeServer("Elevators","Leave")
											getgenv().repeating = true
											s = false
											break
										end
										wait(0.01)
										end
										if Elevators.State.Timer.Value == 0 and s then
											getgenv().status = "Teleporting..."
											wait(60)
											getgenv().status = "Teleport failed!"
											RSRF:InvokeServer("Elevators","Leave")
										else
											getgenv().status = "Teleport failed! (Timer)"
											RSRF:InvokeServer("Elevators","Leave")
											getgenv().repeating = true
										end
									end
									if getgenv().Maps[mp.Value] ~= nil and rq == getgenv().MultiStratType then
										if antimulti then
											if (plrs.Value > 1) then
												RSRF:InvokeServer("Elevators","Leave")
												prints("Someone joined, leaving elevator...")
												getgenv().status = "Someone joined..."
												getgenv().repeating = true
												break
											elseif (plrs.Value == 0) then
												wait(1)
												if (plrs.Value == 0) then
													wait(1)
													if (plrs.Value == 0) then
														wait(1)
														if (plrs.Value == 0) then
															wait(1)
															if (plrs.Value == 0) then
															prints("Error")
															getgenv().status = "Error occured, check dev con"
															prints("Error occured, please open ticket on Money Maker Development discord server!")
															RSRF:InvokeServer("Elevators","Leave")
															getgenv().repeating = true
															break
															end
														end
													end
												end
											end
										end
									else
										RSRF:InvokeServer("Elevators","Leave")
										prints("Map changed while joining, leaving...")
										getgenv().status = "Map changed..."
										getgenv().repeating = true
										break
									end
								end
							end
						end
					end
					if jc == 0 then
						getgenv().repeating = true
						prints("Waiting for map...")
						getgenv().status = "Waiting for map..."
						if getgenv().timer >= 15 then
						getgenv().status = "Force changing maps..."
						getgenv().timer = 0
						for i, v in pairs(game:GetService('Workspace').Elevators:GetChildren()) do
							local plrs = v.State.Players
							local rq = require(v.Settings).Type
							if plrs.Value <= 0 and rq == getgenv().MultiStratType then
								RSRF:InvokeServer("Elevators","Enter",v)
								wait(1)
								RSRF:InvokeServer("Elevators","Leave")
							end
						end
						wait(0.6)
						RSRF:InvokeServer("Elevators","Leave")
						wait(1)
					end
				end
			end
		end
	end)
end
end)
