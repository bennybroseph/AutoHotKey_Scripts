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

class Image
{
	static __imageCount := 0

	__New(p_Filepath, p_Scale := 1, p_BackgroundColor := 0x00000000)
	{
		local _index := ++Image.__imageCount
		this.m_Index := _index

		Gui, %_index%: -Caption +E0x80000 +LastFound +Owner +AlwaysOnTop +ToolWindow
		Gui, %_index%: Show, NA
		WinSet, ExStyle, +0x20

		this.m_HWND := WinExist()

		this.m_Image := Gdip_CreateBitmapFromFile(p_Filepath)
		this.m_Size
			:= new Vector2(Gdip_GetImageWidth(this.m_Image) * p_Scale
						, Gdip_GetImageHeight(this.m_Image) * p_Scale)

		this.m_HBM := CreateDIBSection(this.m_Size.Width, this.m_Size.Height)
		this.m_HDC := CreateCompatibleDC()
		this.m_OBM := SelectObject(this.m_HDC, this.m_HBM)
		this.m_Graphic := Gdip_GraphicsFromHDC(this.m_HDC)

		Gdip_SetInterpolationMode(this.m_Graphic, 7)

		if (p_BackgroundColor != 0x00000000)
		{
			Gdip_SetCompositingMode(this.m_Graphic, 0)

			this.m_Brush := Gdip_BrushCreateSolid(p_BackgroundColor)
			Gdip_FillRectangle(this.m_Graphic, this.m_Brush, 0, 0, this.m_Size.Width, this.m_Size.Height)

			Gdip_DeleteBrush(this.m_Brush)
		}

		Gdip_DrawImage(this.m_Graphic, this.m_Image, 0, 0, this.m_Size.Width, this.m_Size.Height)
		UpdateLayeredWindow(this.m_HWND, this.m_HDC, 0, 0, this.m_Size.Width , this.m_Size.Height)

		Gdip_DisposeImage(this.m_Image)
	}

	Index[]
	{
		get {
			return this.m_Index
		}
	}
	Size[]
	{
		get {
			return this.m_Size
		}
	}
	__Delete()
	{
		SelectObject(this.m_HDC, this.m_OBM)
		DeleteObject(this.m_HBM)
		DeleteDC(this.m_HDC)
		Gdip_DeleteGraphics(this.m_HWND)
	}
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
	static __singleton :=
	static __init := False

	Init()
	{
		Graphics.__singleton := new Graphics()

		if WinExist(this.ApplicationTitle)
			WinActivate ; Activate Application Window if it exists

		this.SetActiveWinStats()
		if (this.ActiveWinStats.Size.Height > 1080)
			ToolTipFont("s10")

		Debug.AddToOnToolTip(new Delegate(Graphics, "OnToolTip"))
		Graphics.__init := False
	}

	__New()
	{
		global

		this.m_ApplicationTitle := IniReader.ReadProfileKey(ProfileSection.Preferences, "Application_Name")

		this.m_ActiveWinStats := new WinStats()

		this.m_BaseResolution
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Base_Resolution_Height")
						,IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Base_Resolution_Width"))
		this.m_CenterOffset
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_Offset_X")
						, IniReader.ReadProfileKey(ProfileSection.AnalogStick, "Center_Offset_Y"))

		if (!this.m_Token := Gdip_Startup())
		{
			MsgBox, 48, % "Gdiplus error!, Gdiplus failed to start. Please ensure you have Gdiplus on your system."
			return
		}

		this.m_Reticule := new Image("Images\Target.png")
	}

	ApplicationTitle[]
	{
		get {
			return this.__singleton.m_ApplicationTitle
		}
	}

	ActiveWinStats[]
	{
		get {
			return this.__singleton.m_ActiveWinStats
		}
		set {
			return this.__singleton.m_ActiveWinStats := value
		}
	}

	BaseResolution[]
	{
		get {
			return this.__singleton.m_BaseResolution
		}
	}
	CenterOffset[]
	{
		get {
			return this.__singleton.m_CenterOffset
		}
	}

	Reticule
	{
		get {
			return this.__singleton.m_Reticule
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

		this.ActiveWinStats.Center.X := (this.ActiveWinStats.Size.Width / 2)
		this.ActiveWinStats.Center.Y := (this.ActiveWinStats.Size.Height / 2)

		if (WinActive(this.ApplicationTitle))
		{
			this.ActiveWinStats.Center.X
				:= this.ActiveWinStats.Center.X + this.CenterOffset.X * (this.ActiveWinStats.Size.Width / this.BaseResolution.Width)
			this.ActiveWinStats.Center.Y
				:= this.ActiveWinStats.Center.Y + this.CenterOffset.Y * (this.ActiveWinStats.Size.Height / this.BaseResolution.Height)
		}
	}

	DrawImage(p_Image, p_Pos, p_CenterImage := True)
	{
		local _imageX := p_Pos.X
		local _imageY := p_Pos.Y

		if (p_CenterImage)
		{
			_imageX := _imageX - (p_Image.Size.Width / 2)
			_imageY := _imageY - (p_Image.Size.Height / 2)
		}
		local _index := p_Image.Index

		Gui, %_index%:Show, x%_imageX% y%_imageY% NoActivate
	}
	HideImage(p_Image)
	{
		local _index := p_Image.Index
		Gui, %_index%:Hide
	}

	DrawReticule(p_Pos, p_CenterImage := True)
	{
		this.DrawImage(this.Reticule, p_Pos, p_CenterImage)
	}
	HideReticule()
	{
		this.HideImage(this.Reticule)
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

	DrawImageOverlay()
	{
		global

		local _imageOverlay := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Enable_Image_Overlay")
		if (!_imageOverlay)
			return

		local _baseResolution
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Base_Resolution_Width")
						, IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Base_Resolution_Height"))

		local _imageScale := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Scale")
		_imageScale := _imageScale * (this.ActiveWinStats.Size.Height / _baseResolution.Height)

		local _imageSet := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Set")
		local _imageSetSize := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Set_Size")
		Loop
		{
			local _newImageKey := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . A_Index . "_Keybind")
			if (_newImageKey = Error)
				break

			local _newImageKeybind := IniReader.ParseKeybind(_newImageKey)
			local _newImagePos
				:= new Vector2(IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . A_Index . "_Pos_X")
							, IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . A_Index . "_Pos_Y"))

			_newImagePos.X := _newImagePos.X * (this.ActiveWinStats.Size.Width / _baseResolution.Width)
			_newImagePos.Y := _newImagePos.Y * (this.ActiveWinStats.Size.Height / _baseResolution.Height)

			_newImagePos.X := _newImagePos.X + this.ActiveWinStats.Pos.X
			_newImagePos.Y := _newImagePos.Y + this.ActiveWinStats.Pos.Y

			local _newImageBackground = IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . A_Index . "_Background")

			local _controlInfo := Controller.FindControlInfo(_newImageKeybind)

			local _newImagePath
				:= "Images\" . _imageSet . "\" . _controlInfo.Act . "\" . _imageSetSize . "\" . _controlInfo.Control.Key . ".png"
			local _newImage := new Image(_newImagePath, _imageScale, _newImageBackground)

			Debug.AddToLog(_controlInfo.Control.Key)

			this.DrawImage(_newImage, _newImagePos)
		}
	}

	OnToolTip()
	{
		local _debugText
			:= "'" . this.ActiveWinStats.Title . "' "
					. "Size: (" . Round(this.ActiveWinStats.Size.Width, 2) . ", " . Round(this.ActiveWinStats.Size.Height, 2) . ") "
					. "Pos: (" . this.ActiveWinStats.Pos.X . ", " . this.ActiveWinStats.Pos.Y . ") "
					. "Center: (" . Round(this.ActiveWinStats.Center.X, 2) . ", " . Round(this.ActiveWinStats.Center.Y, 2) . ")"

		return _debugText
	}

	__Delete()
	{
		Gdip_Shutdown(this.m_Token)
	}
}