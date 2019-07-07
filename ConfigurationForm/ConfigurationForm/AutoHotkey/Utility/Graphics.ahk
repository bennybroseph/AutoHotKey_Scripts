; Assists with everything related to the screen and drawing things to it

class WinStats
{
	__New(p_Title := "", p_Size := 0, p_Pos := 0, p_Center := 0)
	{
		this.m_Title := p_Title

		this.m_Size := p_Size
		if (this.m_Size = 0)
			this.m_Size := new Vector2()

		this.m_Pos := p_Pos
		if (this.m_Pos = 0)
			this.m_Pos := new Vector2()

		this.m_Center := p_Center
		if (this.m_Center = 0)
			this.m_Center := new Vector2()
	}

	Title[]
	{
		get {
			return this.m_Title
		}
		set {
			return this.m_Title := value
		}
	}

	Size[]
	{
		get {
			return this.m_Size
		}
		set {
			return this.m_Size := value
		}
	}
	Pos[]
	{
		get {
			return this.m_Pos
		}
		set {
			return this.m_Pos := value
		}
	}
	Center[]
	{
		get {
			return this.m_Center
		}
		set {
			return this.m_Center := value
		}
	}
}

class Graphics
{
	static __singleton :=
	static __init := False

	Init()
	{
		Graphics.__singleton := new Graphics()

		Debug.AddToOnTooltip(new Delegate(Graphics, "OnTooltip"))
		Graphics.__init := False
	}

	__New()
	{
		this.m_ApplicationTitle := IniReader.ReadProfileKey(ProfileSection.Preferences, "Application_Name")

		this.m_ActiveWinStats := new WinStats()
		this.m_CenterOffset
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_XOffset")
						, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_YOffset"))
	}

	ApplicationTitle[]
	{
		get {
			return Graphics.__singleton.m_ApplicationTitle
		}
	}

	ActiveWinStats[]
	{
		get {
			return Graphics.__singleton.m_ActiveWinStats
		}
		set {
			return Graphics.__singleton.m_ActiveWinStats := value
		}
	}
	CenterOffset[]
	{
		get {
			return Graphics.__singleton.m_CenterOffset
		}
	}

	GetActiveWinStats()
	{
		local _title, _width, _height, _x, _y
		WinGetActiveStats, _title, _width, _height, _x, _y

		local _winStats := new WinStats(_title, new Vector2(_width, _height), new Vector2(_x, _y))

		return _winStats
	}

	SetActiveWinStats()
	{
		this.ActiveWinStats := this.GetActiveWinStats()

		this.ActiveWinStats.Center.X := this.ActiveWinStats.Pos.X + (this.ActiveWinStats.Size.Width / 2)
		this.ActiveWinStats.Center.Y := this.ActiveWinStats.Pos.Y + (this.ActiveWinStats.Size.Height / 2)

		if (WinActive(this.ApplicationTitle))
		{
			this.ActiveWinStats.Center.X := this.ActiveWinStats.Center.X + this.CenterOffset.X
			this.ActiveWinStats.Center.Y := this.ActiveWinStats.Center.Y + this.CenterOffset.Y
		}
	}

	OnTooltip()
	{
		local _debugText
			:= "'" . this.ActiveWinStats.Title . "' "
					. "Size: (" . this.ActiveWinStats.Size.Width . ", " . this.ActiveWinStats.Size.Height . ") "
					. "Pos: (" . this.ActiveWinStats.Pos.X . ", " . this.ActiveWinStats.Pos.Y . ") "
					. "Center: (" . this.ActiveWinStats.Center.X . ", " . this.ActiveWinStats.Center.Y . ")"

		return _debugText
	}
}