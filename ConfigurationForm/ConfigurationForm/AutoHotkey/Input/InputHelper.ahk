; Helps with pressing and releasing input

class InputHelper
{
	MoveMouse(p_Pos, p_Speed := "", p_IsRelative := "")
	{
		MouseMove, % p_Pos.X, % p_Pos.Y, % p_Speed, % p_IsRelative
	}

	PressKeybind(p_Keybind)
	{
		if (p_Keybind.Modifier)
			this.PressKey(p_Keybind.Modifier)
		this.PressKey(p_Keybind.Action)
	}
	ReleaseKeybind(p_Keybind)
	{
		this.ReleaseKey(p_Keybind.Action)
		if (p_Keybind.Modifier)
			this.ReleaseKey(p_Keybind.Modifier)
	}

	PressKey(p_Key)
	{
		local _isSpecial := p_Key = "Freedom" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory"
		if (_isSpecial)
			this.PressSpecialKey(p_Key)
		else
			Send { %p_Key% Down }
	}
	ReleaseKey(p_Key)
	{
		local _isSpecial := p_Key = "Freedom" or p_Key = "Loot" or p_Key = "FreeTarget" or p_Key = "Inventory"
		if (_isSpecial)
			this.ReleaseSpecialKey(p_Key)
		else
			Send { %p_Key% Up }
	}

	PressSpecialKey(p_SpecialKey)
	{
		if (p_SpecialKey = "Freedom")
			Controller.ToggleCursorMode()
	}
	ReleaseSpecialKey(p_SpecialKey)
	{

	}
}