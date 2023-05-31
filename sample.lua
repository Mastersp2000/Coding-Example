--EVERYTHING HERE WAS MADE BY MASTERSP2000/MASTERKURIETA
function buildSequence() -- This function builds a colorSequence based off of how many bars the player has created in the Colour Menu.
	local barCount = 0
	for i,v in pairs(script.Parent.ColourFrame.Frame:GetChildren()) do
		if v:IsA("ImageButton") then
			if string.sub(v.Name, 0, 8) == "stillbar" then 
				barCount += 1
				v.Name = "stillbar_"..barCount 
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

function buildNumSequenceV2() -- This function builds a number sequence based on the user's inputs in the advanced menu.
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
	local function SetBarcount(targetFrame) -- Loops through an object and organises the names of frames. E.G If a frame/bar is deleted, the ones left will be renamed appropiately.
		for i,v in pairs(targetFrame:GetChildren()) do
			if string.sub(v.Name, 0, 8) == "stillbar" then
				barcount += 1
				v.Name = "stillbar_"..barcount
			end
		end
	end
	local function GetKeypoints(targetFrame) -- Function that reads the values from the textboxes and creates and returns a numberKey/Sequence
		local NumKey = nil
		local returnedSet = nil
		if barcount > 2 then --Failsafe to stop the player from creating/applying more than 3 bars
			local s, e = pcall(function()
				targetFrame:FindFirstChild("stillbar_3")
			end)
			if s then
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
				return nil
			end
		end
	end
	local function SetSequence(selected) -- The values from the GetKeypoints function are read by this function and then applied to the placeholder particle emitter.
		local sizeKeypoints = nil
		local targetFrame = numberFrame:FindFirstChild("Frame"..selected)
		local returned = nil
		SetBarcount(targetFrame)
		local success, e = pcall(function()
			if type(tonumber(targetFrame.startButton.TextBox.Text)) ~= "number" then return false end --Failsafe to stop the player from entering a letter where an integer should be
			returned = GetKeypoints(targetFrame)
		end)
		if success then
			if returned ~= nil then
				NumSeq = NumberSequence.new(returned)
				if script.Parent.NumberFrame.SwapButton.Text == "Size" then
					folder.NumberSequence.SizeEmitter.Size = NumSeq --If the player has size selected, it will assign their values to the Size of a particle emitter placeholder.
				end
				if script.Parent.NumberFrame.SwapButton.Text == "Transparency" then
					folder.NumberSequence.TransparencyEmitter.Transparency = NumSeq
				end
				
			end
			
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

function createImage(ImageID, bool) -- Simple function to allow the player to add their own particle texture to the game using an rbxasset ID.
	if script.Parent.ImageFrame.ScrollingFrame:FindFirstChild("Image_"..ImageID) then return end
	
	local image = Instance.new("ImageButton") --Creates an image button, which displays the player's particle texture.
	image.Parent = script.Parent.ImageFrame.ScrollingFrame
	image.Name = "Image_"..ImageID
	image.Image = ImageID
	image.BorderColor3 = Color3.fromRGB(0, 124, 169)
	image.BorderSizePixel = 0
	
	image.MouseButton1Click:Connect(function() -- function that allows the player to switch between different particle textures.
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

UIS.InputBegan:Connect(function(input) -- Function that checks the textbox where the player would enter an rbxasset id.
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
					if infoTab["AssetTypeId"] == 1 or 13 then -- Roblox only displays asset 1 (Images) on imageLabels/Buttons. Entering a 13(decal) will not work
						warn("valid ID")
						createImage(Textbox.Text) -- Creates an imagebutton if the assetID is valid
						Textbox.Text = ""
					end
				end
			else
				local number
				
				local success, errorMessage = pcall(function()
					number = tonumber(Textbox.Text)
				end)
				if success then
					if Textbox.Parent.Parent.Visible == false then return end
					if Textbox.Text == "" then return end
					local succ, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, tonumber(Textbox.Text))
					if succ == false then
						sendError("Error", "A texture with that ID could not be found!")
					end
					if succ == true then
						local infoTab = info
						if infoTab["AssetTypeId"] == 1 or 13 then -- Roblox only displays asset 1 (Images) on imageLabels/Buttons. Entering a 13(decal) will not work
							warn("valid ID")
							createImage("rbxassetid://"..Textbox.Text) -- Creates an imagebutton if the assetID is valid
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
