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
		Send { %p_Key% Down }
	}
	ReleaseKey(p_Key)
	{
		Send { %p_Key% Up }
	}
}