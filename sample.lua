--EVERYTHING HERE WAS MADE BY MASTERSP2000/MASTERKURIETA
function buildSequence() -- This function builds a colorSequence based off of how many bars the player has created in the Colour Menu.
	local barCount = 0
	for i,v in pairs(script.Parent.ColourFrame.Frame:GetChildren()) do -- loop that gets the children of a gradient colour bar
		if v:IsA("ImageButton") then -- the sliders you can move on the bar are all imagebuttons, hence why I am making this condition to only run the following code if the child is an imagebutton.
			if string.sub(v.Name, 0, 8) == "stillbar" then --if the first 8 characters are "stillbar". This is because the bars are generated by code, and are named "stillbar_1/2/3"
				barCount += 1
				v.Name = "stillbar_"..barCount  
			end
		end
	end
	if barCount == 1 then --The player has 2 pars that cannot be moved, and a maximum of creating 2 that can be moved, 1barcount + 2 = 3 total
		local colorKeypoints = { -- setting colour keypoints to whatever the player entered for each bar. This isn't in a pcall because they are other failsafes that check the value of each bar, etc, etc that are not included in this sample.
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
		-- loops through textboxes and assigns values, all failsafes should be in this function. This was an old comment from the og code.
		for i,v in pairs(targetFrame:GetChildren()) do  --loop that gets the children of whatever object you enter 😱
			if v:IsA("ImageButton") then -- if a child is an imagebutton then proceed
				local success, e = pcall(function() -- This is here to stop any error from occuring if the player entered a letter where a number should be.
					if type(tonumber(v.TextBox.Text)) == "number" then -- Funny conditional that runs the "tonumber" function and checks to see if that output is a number.
 					v.NumberValue.Value = v.TextBox.Text
					end
				end)
				if success then
					funcSucc = true -- sets the value to return
				end
				if not success then
					warn("An error occured in: 'SetValues' that was not caught.\nError:\n"..e) -- an Error?!?! 😱
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
				if script.Parent.NumberFrame.SwapButton.Text == "Size" then --if statement 
					folder.NumberSequence.SizeEmitter.Size = NumSeq --If the player has size selected, it will assign their values to the Size of a particle emitter placeholder.
				end
				if script.Parent.NumberFrame.SwapButton.Text == "Transparency" then
					folder.NumberSequence.TransparencyEmitter.Transparency = NumSeq --If the player has transparency selected, it will assign their values to the Transparency of a particle emitter placeholder.
				end
				
			end
			
		end
		if not success then
			warn(e)
		end
	end

	if script.Parent.NumberFrame.SwapButton.Text == "Size" then -- really bad code that figures out what the player has selected to edit and runs the setSequence function based off of the button's text
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
			selectedImage = image --essentially makes it look like the player is selecting the images which display their textures
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
		if Textbox.Text ~= nil then -- if the player didn't type anything don't run the rest of the code!!!
			if string.sub(Textbox.Text, 0, 13) == "rbxassetid://" then --if the first 13 letters begin with rbxassetid:// then continue
				local IDlen = string.len(Textbox.Text)
				local textureID = string.sub(Textbox.Text, 14, IDlen)-- set the variable texture id to cut out the rbxassetid:// part so your left with the number
				print(textureID)
				local succ, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, textureID) --pcall so i can catch an error. check the marketplace to see if a texture with that ID actually exsists
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
			else --if there is no rbxassetid:// the script assumes the player has just entered a number- not efficient I know I know
				local number -- variable 😱
				
				local success, errorMessage = pcall(function()--pcall so no sneaky error
					number = tonumber(Textbox.Text) -- Attempt to set whatever the player has entered into the textbox as a number, if it's letters the code just prints an error and nothing happens.
				end)
				if success then -- if it is a number 😱
					if Textbox.Parent.Parent.Visible == false then return end
					if Textbox.Text == "" then return end
					local succ, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, tonumber(Textbox.Text)) --use marketplace api to see if the id the player entered is real?!?! 😱
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
