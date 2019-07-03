; Defines both keybindings and Inputbindings

class Keybind
{
    __New()
    {        
        this.m_Action   := ""        
        this.m_Modifier := ""        
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
        this.Press  := new Keybind()
        MsgBox, 1, Title, Made it to keybind
        this.Hold   := new Keybind()
    }

    Press[]
    {
        get {
            return this.Press
        }
        set {
            return this.Press := value
        }
    }
    Hold[]
    {
        get {
            return this.Hold
        }
        set {
            return this.Hold := value
        }
    }
}