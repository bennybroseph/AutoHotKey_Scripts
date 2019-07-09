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
			this.ReleaseKeybind(Controller.MoveOnlyKey)
			Controller.ForceMouseUpdate := True

			if (p_Keybind.Type = KeybindType.Targeted)
			{
				local _mousePos := Controller.TargetPos
				if (!Controller.TargetStick.State and !Controller.FreeTargetMode)
					_mousePos := Controller.MousePos

				this.MoveMouse(_mousePos)

				Controller.PressCount.Targeted++
			}
			else if (p_Keybind.Type = KeybindType.Movement)
			{
				this.MoveMouse(Controller.MousePos)

				Controller.PressCount.Movement++
			}

			Controller.PressStack.Push(p_Keybind)

			if (True)
					Sleep, 5
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
			if (p_Keybind.Type = KeybindType.Targeted)
			{
				Controller.PressCount.Targeted--

				if (Controller.PressCount.Targeted = 0)
				{
					Controller.ForceMouseUpdate := True

					if (True)
						Sleep, 5
					this.MoveMouse(Controller.MousePos)

					if (Controller.UsingReticule or Controller.ForceReticuleUpdate)
						Graphics.DrawReticule(Controller.TargetPos)
				}
			}
			else if (p_Keybind.Type = KeybindType.Movement)
			{
				Controller.PressCount.Movement--
			}

			Controller.PressStack.Remove(p_Keybind)
		}
	}

	PressKey(p_Key)
	{
		local _isSpecial := p_Key = "Freedom" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory"
		if (_isSpecial)
			this.PressSpecialKey(p_Key)
		else
			Send {%p_Key% Down}
	}
	ReleaseKey(p_Key)
	{
		local _isSpecial := p_Key = "Freedom" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory"
		if (_isSpecial)
			this.ReleaseSpecialKey(p_Key)
		else
			Send {%p_Key% Up}
	}

	PressSpecialKey(p_SpecialKey)
	{
		global

		if (p_SpecialKey = "Freedom")
			Controller.ToggleCursorMode()
		else if (p_SpecialKey = "FreeTarget")
			Controller.ToggleFreeTargetMode()
		else if (p_SpecialKey = "Loot")
			SetTimer, SpamLoot, 100
	}
	ReleaseSpecialKey(p_SpecialKey)
	{
		if (p_SpecialKey = "Loot")
			SetTimer, SpamLoot, Off
	}
}