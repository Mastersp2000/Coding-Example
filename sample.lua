function buildSequence()
	local barCount = 0
	for i,v in pairs(script.Parent.ColourFrame.Frame:GetChildren()) do
		if v:IsA("ImageButton") then
			if string.sub(v.Name, 0, 8) == "stillbar" then 
				barCount += 1
				v.Name = "stillbar_"..barCount 
				--print(barCount)
			end
		end
	end
	if barCount == 1 then
		local colorKeypoints = {
			ColorSequenceKeypoint.new(0, interiorColourFrame.Frame.startButton.ColorValue.Value),
			ColorSequenceKeypoint.new(tonumber(interiorColourFrame.Frame.stillbar_1.ColorValue.Time.Value), interiorColourFrame.Frame.stillbar_1.ColorValue.Value),
			ColorSequenceKeypoint.new(1, interiorColourFrame.Frame.endButton.ColorValue.Value)
		}
		gradient.UIGradient.Color = ColorSequence.new(colorKeypoints)
	end
	if barCount == 2 then
		if tonumber(interiorColourFrame.Frame.stillbar_1.ColorValue.Time.Value) > tonumber(interiorColourFrame.Frame.stillbar_2.ColorValue.Time.Value) then
			sendError("Error,", "You must not place your second marker before the first marker.\nThe marker will be destroyed.")
			interiorColourFrame.Frame:FindFirstChild("stillbar_2"):Destroy()
			barCount = 1
			return
		end
		local colorKeypoints = {
			ColorSequenceKeypoint.new(0, interiorColourFrame.Frame.startButton.ColorValue.Value),
			ColorSequenceKeypoint.new(tonumber(interiorColourFrame.Frame.stillbar_1.ColorValue.Time.Value), interiorColourFrame.Frame.stillbar_1.ColorValue.Value),
			ColorSequenceKeypoint.new(tonumber(interiorColourFrame.Frame.stillbar_2.ColorValue.Time.Value), interiorColourFrame.Frame.stillbar_2.ColorValue.Value),
			ColorSequenceKeypoint.new(1, interiorColourFrame.Frame.endButton.ColorValue.Value)
		}
		gradient.UIGradient.Color = ColorSequence.new(colorKeypoints)	
	end
	
end

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

function createImage(ImageID, bool)
	if script.Parent.ImageFrame.ScrollingFrame:FindFirstChild("Image_"..ImageID) then return end
	
	local image = Instance.new("ImageButton")
	image.Parent = script.Parent.ImageFrame.ScrollingFrame
	image.Name = "Image_"..ImageID
	image.Image = ImageID
	--image.BackgroundTransparency = 1
	image.BorderColor3 = Color3.fromRGB(0, 124, 169)
	image.BorderSizePixel = 0
	
	image.MouseButton1Click:Connect(function()
		if selectedImage == nil then
			print(image)
			image.BorderSizePixel = 3
			selectedImage = image
		else
			
			selectedImage.BorderSizePixel = 0
			image.BorderSizePixel = 3
			selectedImage = image
		end
		
	end)
	if bool == true then
		image.BorderSizePixel = 3
		selectedImage = image
	end
end
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Return then
		if Textbox.Text ~= nil then
			if string.sub(Textbox.Text, 0, 13) == "rbxassetid://" then
				local IDlen = string.len(Textbox.Text)
				local textureID = string.sub(Textbox.Text, 14, IDlen)
				print(textureID)
				local succ, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, textureID)
				if succ == false then
					warn(info)
					sendError("Error", "A texture with that ID could not be found")
					sendError("Error Information", info)
				end
				if succ == true then
					local infoTab = info
					if infoTab["AssetTypeId"] == 1 or 13 then
						warn("valid ID")
						createImage(Textbox.Text)
						Textbox.Text = ""
					end
				end
			else
				local number
				
				local success, errorMessage = pcall(function()
					number = tonumber(Textbox.Text)
				end)
				if success then
					--print("roblox ID")
					if Textbox.Parent.Parent.Visible == false then return end
					if Textbox.Text == "" then return end
					local succ, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, tonumber(Textbox.Text))
					if succ == false then
						sendError("Error", "A texture with that ID could not be found!")
					end
					if succ == true then
						local infoTab = info
						--print(info)
						if infoTab["AssetTypeId"] == 1 or 13 then
							warn("valid ID")
							--print(info)
							createImage("rbxassetid://"..Textbox.Text)
							--selectedImage = Textbox.Text
							Textbox.Text = ""
						end
					end
					
				end
				if not success then
					sendError("Error", "An error occured.")
				end
			end
		end
	end
end)
