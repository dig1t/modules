--[=[
	AutoCanvasSize

	Author: dig1t

	Description: A function that automatically resizes the canvas of a ScrollingFrame to perfectly
	fit all contents when a new child is added, changed, removed, or if the player screen resizes.

	Either UIListLayout or UIGridLayout must be a child of
	the ScrollingFrame in order for this function to work.

	It returns a connection that can be used to disconnect the automatic resizing.
	This is useful when the ScrollingFrame is no longer needed, such as when the parent ScreenGui
	is no longer Enabled or when the ScrollingFrame is destroyed.

	Usage:
	```lua
	local AutoCanvasSize = require(ReplicatedStorage.Modules.AutoCanvasSize)

	local myScrollingFrame = Players.LocalPlayer.PlayerGui.Inventory.ScrollingFrame
	local connection = AutoCanvasSize(myScrollingFrame)

	-- To stop automatic canvas resizing
	connection:Disconnect()
	```
]=]

--!strict

local function AutoCanvasSize(scrollingFrame: ScrollingFrame): RBXScriptConnection?
	-- Having AutomaticCanvasSize on the ScrollingFrame breaks this canvas size resizer module
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None

	local uiLayout = scrollingFrame:FindFirstChildWhichIsA("UIListLayout")
		or scrollingFrame:FindFirstChildWhichIsA("UIGridLayout")

	if not uiLayout then
		warn("UIListLayout or UIGridLayout must be a child of the given ScrollingFrame")
		return nil
	end

	-- Save the original canvas size's X axis
	local canvasSizeRef = UDim2.new(
		scrollingFrame.CanvasSize.X.Scale,
		scrollingFrame.CanvasSize.X.Offset,
		0,
		0
	)

	local function handleResize()
		local canvasYPositionInScreen = scrollingFrame.AbsolutePosition.Y
		local canvasHeight = 0

		for _, guiObject in scrollingFrame:GetChildren() do
			if not guiObject:IsA("GuiObject") or not guiObject.Visible then
				continue
			end

			-- Get the position of the object relative to the screen
			-- This will be the top position of the gui object
			local objectPositionInScreen = guiObject.AbsolutePosition.Y
				- canvasYPositionInScreen

			-- Get the bottom position of the object relative to the screen
			-- This will be used to calculate the canvas height
			local objectBottomY = objectPositionInScreen + guiObject.AbsoluteSize.Y

			-- Update the canvas height if the object is lower than the current canvas height
			if objectBottomY > canvasHeight then
				canvasHeight = objectBottomY
			end
		end

		-- Update the canvas size of the scrolling frame
		scrollingFrame.CanvasSize = canvasSizeRef
			+ UDim2.fromOffset(0, uiLayout.AbsoluteContentSize.Y)
	end

	handleResize()

	return uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(handleResize)
end

return AutoCanvasSize
