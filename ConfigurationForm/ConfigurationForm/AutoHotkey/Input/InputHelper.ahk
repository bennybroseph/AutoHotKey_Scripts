; Helps with pressing and releasing input

class InputHelper
{
	MoveMouse(p_Pos, p_Speed := "", p_IsRelative := "")
	{
		MouseMove, % p_Pos.X, % p_Pos.Y, % p_Speed, % p_IsRelative
	}
	GetMousePos()
	{
		local _mousePosX, _mousePosY
		MouseGetPos, _mousePosX, _mousePosY

		return new Vector2(_mousePosX, _mousePosY)
	}

	PressKeybind(p_Keybind)
	{
		global

		if (p_Keybind.Type != KeybindType.UnTargeted)
		{
			Controller.ForceMouseUpdate 	:= True
			Controller.ForceReticuleUpdate 	:= True

			if (p_Keybind.Type = KeybindType.Targeted)
			{
				local _newMousePos := Controller.TargetPos
				if (!Controller.TargetStick.State and !Controller.FreeTargetMode)
					_newMousePos := Controller.MousePos

				this.MoveMouse(_newMousePos)

				Controller.PressCount.Targeted++
			}
			else if (p_Keybind.Type = KeybindType.Movement)
			{
				Controller.StopMoving()
				this.MoveMouse(Controller.MousePos)

				Controller.PressCount.Movement++
			}

			Controller.PressStack.Push(p_Keybind)

			if (Controller.TargetingDelay > 0)
					Sleep, % Controller.TargetingDelay
		}

		if (p_Keybind.Modifier)
			this.PressKey(p_Keybind.Modifier)
		this.PressKey(p_Keybind.Action)
	}
	ReleaseKeybind(p_Keybind)
	{
		global

		this.ReleaseKey(p_Keybind.Action)
		if (p_Keybind.Modifier)
			this.ReleaseKey(p_Keybind.Modifier)

		if (p_Keybind.Type != KeybindType.UnTargeted)
		{
			Controller.ForceMouseUpdate 	:= True
			Controller.ForceReticuleUpdate 	:= True

			Debug.AddToLog(p_Keybind.Action . " released")
			Controller.PressStack.Remove(p_Keybind)

			if (p_Keybind.Type = KeybindType.Targeted)
				Controller.PressCount.Targeted--
			else if (p_Keybind.Type = KeybindType.Movement)
				Controller.PressCount.Movement--
		}
	}

	PressKey(p_Key)
	{
		local _isSpecial
			:= p_Key = "CursorMode" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "SwapSticks" or p_Key = "Inventory"
		if (_isSpecial)
			this.PressSpecialKey(p_Key)
		else
			Send {%p_Key% Down}
	}
	ReleaseKey(p_Key)
	{
		local _isSpecial
			:= p_Key = "CursorMode" or p_Key = "Loot" or p_Key = "FreeTarget"or p_Key = "SwapSticks" or p_Key = "Inventory"
		if (_isSpecial)
			this.ReleaseSpecialKey(p_Key)
		else
			Send {%p_Key% Up}
	}

	PressSpecialKey(p_SpecialKey)
	{
		global

		if (p_SpecialKey = "CursorMode")
			Controller.ToggleCursorMode()
		else if (p_SpecialKey = "FreeTarget")
			Controller.ToggleFreeTargetMode()
		else if (p_SpecialKey = "Inventory")
			Inventory.Toggle()
		else if (p_SpecialKey = "SwapSticks")
			Controller.SwapSticks()
		else if (p_SpecialKey = "Loot")
			SetTimer, SpamLoot, % Controller.LootDelay
	}
	ReleaseSpecialKey(p_SpecialKey)
	{
		if (p_SpecialKey = "Loot")
			SetTimer, SpamLoot, Off
	}
}