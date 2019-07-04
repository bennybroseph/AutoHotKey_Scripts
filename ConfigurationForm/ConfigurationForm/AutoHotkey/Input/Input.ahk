#Include Input\Binding.ahk
#Include Input\InputManager.ahk

class Input
{
    __New(p_Name, p_Nickname, p_Index, p_Key)
    {
        this.m_Name         := p_Name
        this.m_Nickname     := p_Nickname
        this.m_Index        := p_Index
        this.m_Key          := p_Key

        this.m_State        := False
        this.m_PrevState    := this.m_State

        this.m_PressTick    := -1

        this.m_Inputbind   := IniUtility.ParseInputbind(this.m_Key)
    }

    Name[]
    {
        get {
            return this.m_Name
        }
    }
    Nickname[]
    {
        get {
            return this.m_Nickname
        }
    }
    Index[]
    {
        get {
            return this.m_Index
        }
    }
    Key[]
    {
        get {
            return this.m_Key
        }
    }

    State[]
    {
        get {
            return this.m_State
        }
    }
    PrevState[]
    {
        get {
            return this.m_PrevState
        }
    }

    PressTick[]
    {
        get {
            return this.m_PressTick
        }
        set {
            return this.m_PressTick := value
        }
    }

    Inputbind[]
    {
        get {
            return this.m_Inputbind
        }
    }

    IsValidInput[]
    {
        get {
            return True
        }
    }

	ParseTargeting()
	{
		For i, _keybind in InputManager.TargetedKeybinds
		{
			if (this.m_Inputbind.Press.Action = _keybind.Action
			and this.m_Inputbind.Press.Modifier = _keybind.Modifier)
				this.m_Inputbind.Press.IsTargeted := True

			if (this.m_Inputbind.Hold.Action = _keybind.Action
			and this.m_Inputbind.Hold.Modifier = _keybind.Modifier)
				this.m_Inputbind.Hold.IsTargeted := True
		}

		For i, _keybind in InputManager.IgnoreReticuleKeybinds
		{
			if (this.m_Inputbind.Press.Action = _keybind.Action
			and this.m_Inputbind.Press.Modifier = _keybind.Modifier)
				this.m_Inputbind.Press.IgnoreReticule := True

			if (this.m_Inputbind.Hold.Action = _keybind.Action
			and this.m_Inputbind.Hold.Modifier = _keybind.Modifier)
				this.m_Inputbind.Hold.IgnoreReticule := True
		}
	}

    RefreshState(p_State)
    {
        this.m_PrevState := this.m_State
    }
}
class Button extends Input
{
    __New(p_Name, p_Nickname, p_Index, p_Key, p_Bitmask)
    {
        base.__New(p_Name, p_Nickname, p_Index, p_Key)

        this.m_Bitmask := p_Bitmask
    }

    RefreshState(p_State)
    {
        base.RefreshState(p_State)

        ;AddToDebugLog("m_Bitmask: " . this.m_Bitmask)
        this.m_State := p_State.Buttons & this.m_Bitmask
    }
}
class Trigger extends Input
{
   __New(p_Name, p_Nickname, p_Index, p_Key, p_Direction)
    {
        base.__New(p_Name, p_Nickname, p_Index, p_Key)

        this.m_Direction := p_Direction
    }

    IsValidInput[]
    {
        get {
            return this.m_State > 64
        }
    }

    RefreshState(p_State)
    {
        base.RefreshState(p_State)

        this.m_State := (this.m_Direction = "Left") ? p_State.LeftTrigger : p_State.RightTrigger
    }
}