; Defines both keybindings and Inputbindings

class Keybind
{
    __New()
    {
        this.m_Action   :=
        this.m_Modifier :=
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
}
class Inputbind
{
    __New()
    {
        this.m_Press  := new Keybind()
        this.m_Hold   := new Keybind()
    }

    Press[]
    {
        get {
            return this.m_Press
        }
        set {
            return this.m_Press := value
        }
    }
    Hold[]
    {
        get {
            return this.m_Hold
        }
        set {
            return this.m_Hold := value
        }
    }
}