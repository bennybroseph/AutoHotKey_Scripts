; Defines both keybindings and controlbindings

class Keybind
{
    __New()
    {
        this.m_Action   :=
        this.m_Modifier :=

		this.m_IsTargeted := False
		this.m_IgnoreReticule := False
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

	IsTargeted[]
	{
		get {
			return this.m_IsTargeted
		}
		set {
			return this.m_IsTargeted := value
		}
	}
	IgnoreReticule[]
	{
		get {
			return this.m_IgnoreReticule
		}
		set {
			return this.m_IgnoreReticule := value
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