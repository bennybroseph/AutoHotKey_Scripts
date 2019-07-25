; Assists with everything related to the screen and drawing things to it

class HorizontalAlignment
{
	static Left 	:= 0
	static Center 	:= 1
	static Right	:= 2
}
class VerticalAlignment
{
	static Top		:= 0
	static Center	:= 1
	static Bottom	:= 2
}

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
	static m_Token

	static m_ApplicationTitle

	static m_ScreenBounds

	static m_ActiveWinStats
	static m_OnActiveWindowChanged

	static m_BaseResolution
	static m_CenterOffset

	Init()
	{
		global

		if (!this.m_Token := Gdip_Startup())
		{
			MsgBox, 48, % "Gdiplus error!", % "Gdiplus failed to start. Please ensure you have Gdiplus on your system."
			Run, https://github.com/tariqporter/Gdip/blob/master/gdiplus.dll
			ExitApp, -1
		}

		this.m_ApplicationTitle := IniReader.ReadProfileKey(ProfileSection.Preferences, "Application_Name")

		local _maxX, _maxY
		Sysget, _maxX, 78
		Sysget, _maxY, 79

		this.m_ScreenBounds := new Rect(new Vector2(), new Vector2(_maxX, _maxY))

		this.m_ActiveWinStats := new WinStats()
		this.m_OnActiveWindowChanged := new Event()

		this.m_BaseResolution
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Base_Resolution_Height")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Base_Resolution_Width"))
		this.m_CenterOffset
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_Offset_X")
						, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_Offset_Y"))

		if WinExist(this.m_ApplicationTitle)
			WinActivate ; Activate Application Window if it exists

		this.SetActiveWinStats()
		if (this.m_ActiveWinStats.Size.Height > 1080)
			ToolTipFont("s10")

		Debug.OnToolTipAddListener(new Delegate(Graphics, "OnToolTip"))
	}

	ScreenBounds[]
	{
		get {
			return this.m_ScreenBounds
		}
	}

	ActiveWinStats[]
	{
		get {
			return this.m_ActiveWinStats
		}
	}
	OnActiveWindowChanged
	{
		get {
			return this.m_OnActiveWindowChanged
		}
	}

	BaseResolution[]
	{
		get {
			return this.m_BaseResolution
		}
	}
	ResolutionScale[]
	{
		get {
			return Vector2.Div(this.m_ActiveWinStats.Size, this.m_BaseResolution)
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
		local _winStats := this.GetActiveWinStats()
		if (!_winStats.Title)
			return

		local _windowChanged := _winStats.Title != this.m_ActiveWinStats.Title

		this.m_ActiveWinStats := _winStats

		this.m_ActiveWinStats.Center := Vector2.Div(this.m_ActiveWinStats.Size, 2)

		if (WinActive(this.m_ApplicationTitle))
			this.m_ActiveWinStats.Center
				:= Vector2.Add(this.m_ActiveWinStats.Center, Vector2.Mul(this.m_CenterOffset, this.ResolutionScale))

		if (_windowChanged)
		{
			Debug.Log("Active window changed from " . this.m_ActiveWinStats.Title . " to " . _winStats.Title)
			this.m_OnActiveWindowChanged.Invoke()
		}
	}

	GetControlAutoSize(p_Text)
	{
		global

		local _index := "NewGUI"

		Gui, %_index%: Default
		Gui, Font, s11, Consolas
		Gui, Add, Edit, vt2, % p_Text
		GuiControlGet, t2, Pos ; this will work as soon as a control exists, regardless of whether the gui ever gets 'shown'.
		Gui, Destroy

		Gui, 1:Default

		return new Vector2(t2w, t2h)
	}

	DrawToolTip(p_Text
			, p_X
			, p_Y
			, p_Index
			, p_HorizontalAlignment := 0
			, p_VerticalAlignment := 0)
	{
		global

		ToolTip, % p_Text, % p_X, % p_Y, % p_Index

		if (p_HorizontalAlignment = 0 and p_VerticalAlignment = 0)
			return

		local _x, _y, _w, _h
		WinGetPos, _x, _y, _w, _h, ahk_class tooltips_class32

		local _horizontalAdjustment := 0
		if (p_HorizontalAlignment != HorizontalAlignment.Left)
			_horizontalAdjustment
				:= p_HorizontalAlignment = HorizontalAlignment.Center
					? _w / 2 : _w

		local _verticalAdjustment := 0
		if (p_VerticalAlignment != VerticalAlignment.Top)
			_verticalAdjustment
				:= p_VerticalAlignment = VerticalAlignment.Center
					? _h / 2 : _h

		p_X := p_X - _horizontalAdjustment
		p_Y := p_Y - _verticalAdjustment

		ToolTip, % p_Text, % p_X, % p_Y, % p_Index
	}
	HideToolTip(p_Index)
	{
		ToolTip, , , , % p_Index
	}

	GetClientSize(p_HWND)
	{
		global

		local _rc
		VarSetCapacity(_rc, 16)

    	DllCall("GetClientRect", "uint", p_HWND, "uint", &_rc)

		local _size := new Vector2(NumGet(_rc, 8, "int"), NumGet(_rc, 12, "int"))

		return _size
	}

	OnToolTip()
	{
		local _debugText
			.= this.m_ActiveWinStats.Title . "`n"
			. "Size: " this.m_ActiveWinStats.Size.String . "`t"
			. "Pos: " this.m_ActiveWinStats.Pos.String "`n"
			. "Center: " this.m_ActiveWinStats.Center.String

		return _debugText
	}

	__Delete()
	{
		Gdip_Shutdown(this.m_Token)
	}
}