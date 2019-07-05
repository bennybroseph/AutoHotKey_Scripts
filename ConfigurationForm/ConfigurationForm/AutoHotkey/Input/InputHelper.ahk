; Helps with pressing and releasing input

class InputHelper
{
	PressKeybind(p_Keybind)
	{
		if (p_Keybind.Modifier)
			this.PressKey(p_Keybind.Modifier)
		this.PressKey(p_Keybind.Action)
	}
	ReleaseKeybind(p_Keyind)
	{
		this.PressKey(p_Keybind.Action)
		if (p_Keybind.Modifier)
			this.PressKey(p_Keybind.Modifier)
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