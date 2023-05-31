function buildNumSequenceV2()
	local numberFrame = script.Parent.NumberFrame
	local NumSeq = nil
	local barcount = 0 
	local funcSucc 
	
	local function SetValues(targetFrame)
		-- loops through textboxes and assigns values, all failsafes should be in this function
		for i,v in pairs(targetFrame:GetChildren()) do
			if v:IsA("ImageButton") then
				local success, e = pcall(function()
					if type(tonumber(v.TextBox.Text)) == "number" then
						v.NumberValue.Value = v.TextBox.Text
					--[[else
						warn("An error occured whislt trying to set the value of: "..v.Name.." to: "..v.TextBox.Text)
						]]
					end
				end)
				if success then
					funcSucc = true
				end
				if not success then
					warn("An error occured in: 'SetValues' that was not caught.\nError:\n"..e)
					funcSucc = nil
				end
			end
		end
		-- success here
		return funcSucc
	end
	local function SetBarcount(targetFrame)
		for i,v in pairs(targetFrame:GetChildren()) do
			if string.sub(v.Name, 0, 8) == "stillbar" then
				barcount += 1
				v.Name = "stillbar_"..barcount
			end
		end
	end
	local function GetKeypoints(targetFrame)
		local NumKey = nil
		local returnedSet = nil
		if barcount > 2 then
			local s, e = pcall(function()
				targetFrame:FindFirstChild("stillbar_3")
			end)
			if s then
				print("deleted")
				targetFrame:FindFirstChild("stillbar_3"):Destroy()
			end
		end
		if barcount == 1 then
			local success, e = pcall(function()
				returnedSet = SetValues(targetFrame)
				NumKey = {
					NumberSequenceKeypoint.new(0, tonumber(targetFrame.startButton.NumberValue.Value)),
					NumberSequenceKeypoint.new(tonumber(targetFrame.stillbar_1.NumberValue.Time.Value), tonumber(targetFrame.stillbar_1.NumberValue.Value)),
					NumberSequenceKeypoint.new(1, tonumber(targetFrame.endButton.NumberValue.Value))
				}
			end)
			if success then
				if returnedSet == nil then

					warn("\nAn error occured in 'GetKeypoints' when function: 'SetValues' was called. Returned: \n\n"..returnedSet.."\nError:\n"..e)
					return nil
				end
				
				return NumKey
			end
			if not success then
				
				--warn("\nAn error occured in 'GetKeypoints': \n\n"..e)
				return nil
			end
		end
	end
	local function SetSequence(selected)
		local sizeKeypoints = nil
		local targetFrame = numberFrame:FindFirstChild("Frame"..selected)
		local returned = nil
		SetBarcount(targetFrame)
		local success, e = pcall(function()
			if type(tonumber(targetFrame.startButton.TextBox.Text)) ~= "number" then return false end
			returned = GetKeypoints(targetFrame)
		end)
		if success then
			if returned ~= nil then
				--print(returned)
				NumSeq = NumberSequence.new(returned)
				if script.Parent.NumberFrame.SwapButton.Text == "Size" then
					folder.NumberSequence.SizeEmitter.Size = NumSeq
				end
				if script.Parent.NumberFrame.SwapButton.Text == "Transparency" then
					folder.NumberSequence.TransparencyEmitter.Transparency = NumSeq
				end
				
			end
			--actually assign numseq lol
			
		end
		if not success then
			warn(e)
		end
	end

	if script.Parent.NumberFrame.SwapButton.Text == "Size" then
		SetSequence("Size")
	end
	if script.Parent.NumberFrame.SwapButton.Text == "Transparency" then
		SetSequence("Transparency")
	end
end
