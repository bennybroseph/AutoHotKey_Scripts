; Draws the image overlay using Graphics functions

class ImageOverlay
{
	static m_Enabled :=

	static m_BaseResolution :=

	static m_ImageScale :=

	static m_ImageSet :=
	static m_ImageSetSize :=
	static m_Images := Array()

	static m_ShowBatteryStatus :=
	static m_BatteryImages 	:= Array()

	class OverlayImage
	{
		__New(p_Index)
		{
			global

			this.m_Keybind
				:= IniReader.ParseKeybind(IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . p_Index . "_Keybind"))
			this.m_Pos
				:= new Vector2(IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . p_Index . "_Pos_X")
							, IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . p_Index . "_Pos_Y"))

			this.m_Pos.X *= (Graphics.ActiveWinStats.Size.Width / ImageOverlay.m_BaseResolution.Width)
			this.m_Pos.Y *= (Graphics.ActiveWinStats.Size.Height / ImageOverlay.m_BaseResolution.Height)

			this.m_Pos.X += Graphics.ActiveWinStats.Pos.X
			this.m_Pos.Y += Graphics.ActiveWinStats.Pos.Y

			local _colorString := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . p_Index . "_Background")
			if (_colorString != Error)
				this.m_BackgroundColor := IniReader.ParseColor(_colorString)
			else
				this.m_BackgroundColor := -1

			local _controlInfo := Controller.FindControlInfo(this.m_Keybind)

			this.m_FilePath
				:= "Images\" . ImageOverlay.m_ImageSet . "\" . _controlInfo.Act . "\"
				. ImageOverlay.m_ImageSetSize . "\" . _controlInfo.Control.ControlString . ".png"

			this.m_Image := new Image(this.m_FilePath, ImageOverlay.m_ImageScale, this.m_BackgroundColor)
		}

		Image[]
		{
			get {
				return this.m_Image
			}
		}
		Pos[]
		{
			get {
				return this.m_Pos
			}
		}
	}

	Init()
	{
		global

		this.m_Enabled := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Enable_Image_Overlay")
		if (!this.m_Enabled)
			return

		this.m_BaseResolution
			:= new Vector2(IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Base_Resolution_Width")
						, IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Base_Resolution_Height"))

		this.m_ImageScale := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Scale")
		this.m_ImageScale *= Graphics.ActiveWinStats.Size.Height / this.m_BaseResolution.Height

		this.m_ImageSet := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Set")
		this.m_ImageSetSize := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image_Set_Size")

		Loop
		{
			local _newImageKey := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Image" . A_Index . "_Keybind")
			if (_newImageKey = Error)
				break

			this.m_Images.Push(new this.OverlayImage(A_Index))
		}

		this.m_ShowBatteryStatus := IniReader.ReadProfileKey(ProfileSection.ImageOverlay, "Show_Battery_Status")

		this.m_BatteryImages.Push(new Image("Images\Battery_Empty.png", ImageOverlay.m_ImageScale))
		this.m_BatteryImages.Push(new Image("Images\Battery_Low.png", ImageOverlay.m_ImageScale))
		this.m_BatteryImages.Push(new Image("Images\Battery_Medium.png", ImageOverlay.m_ImageScale))
		this.m_BatteryImages.Push(new Image("Images\Battery_High.png", ImageOverlay.m_ImageScale))
	}

	DrawImageOverlay()
	{
		global

		if (!this.m_Enabled)
			return

		local i, _overlayImage
		For i, _overlayImage in this.m_Images
			_overlayImage.Image.Draw(_overlayImage.Pos)
	}
	DrawBatteryStatus()
	{
		global

		if (!this.m_ShowBatteryStatus)
			return

		if (Controller.BatteryStatus.BatteryType != BATTERY_TYPE_WIRED
		and Controller.BatteryStatus.BatteryLevel != Controller.PrevBatteryStatus.BatteryLevel)
		{
			local i, _batteryImage
			For i, _batteryImage in this.m_BatteryImages
			{
				if (Controller.BatteryStatus.BatteryLevel = i - 1)
					_batteryImage.Draw(new Vector2(Graphics.ActiveWinStats.Pos.X, Graphics.ActiveWinStats.Pos.Y), False)
				else
					_batteryImage.Hide()
			}
		}
	}
}