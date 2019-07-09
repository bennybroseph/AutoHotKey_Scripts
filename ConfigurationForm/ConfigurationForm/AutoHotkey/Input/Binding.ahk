; Defines both keybindings and controlbindings

class KeybindType
{
	static Untargeted 	:= "Untargeted"

	static Targeted 	:= "Targeted"
	static Movement 	:= "Movement"
}

class Keybind
{
    __New()
    {
        this.m_Action   :=
        this.m_Modifier :=

		this.m_Type := KeybindType.Untargeted
    }

    Action[]
    {
        get {
            return this.m_Action
        }
        set {
            return this.m_Action := value
        }
    }
    Modifier[]
    {
        get {
            return this.m_Modifier
        }
        set {
            return this.m_Modifier := value
        }
    }

	Type[]
	{
		get {
			return this.m_Type
		}
		set {
			return this.m_Type := value
		}
	}

	String[]
	{
		get {
			local _string :=
			if (this.m_Modifier)
				_string := this.m_Modifier . "+"
			_string := _string . this.m_Action

			return _string
		}
	}
}
class Controlbind
{
    __New()
    {
        this.m_OnPress  := new Keybind()
        this.m_OnHold   := new Keybind()
    }

    OnPress[]
    {
        get {
            return this.m_OnPress
        }
        set {
            return this.m_OnPress := value
        }
    }
    OnHold[]
    {
        get {
            return this.m_OnHold
        }
        set {
            return this.m_OnHold := value
        }
    }
}