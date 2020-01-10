; Contains all graphic items

global GRAPHIC_COUNT := 0

class Graphic
{
	__New()
	{
		global

		local _index := "Image" . ++GRAPHIC_COUNT
		this.m_Index := _index

		this.m_IsDirty := False
		this.m_IsVisible := False

		this.m_Pos := new Vector2()

		Gui, %_index%: -Caption +E0x80000 +LastFound +Owner +AlwaysOnTop +ToolWindow
		Gui, %_index%: Show, NA
		WinSet, ExStyle, +0x20

		this.m_HWND := WinExist()

		this.m_HBM := CreateDIBSection(this.m_Size.Width, this.m_Size.Height)
		this.m_HDC := CreateCompatibleDC()
		this.m_OBM := SelectObject(this.m_HDC, this.m_HBM)
		this.m_Graphics := Gdip_GraphicsFromHDC(this.m_HDC)

		this.SetDrawingMode()

		Gui, %_index%: Hide
	}

	Index[]
	{
		get {
			return this.m_Index
		}
	}
	IsVisible[]
	{
		get {
			return this.m_IsVisible
		}
	}

	Size[]
	{
		get {
			return this.m_Size
		}
	}

	SetDrawingMode() {
	}

	DrawGraphic() {
	}

	UpdateSize(p_Size)
	{
		SelectObject(this.m_HDC, this.m_OBM)
		DeleteObject(this.m_HBM)
		Gdip_DeleteGraphics(this.m_Graphics)

		this.m_Size := p_Size

		this.m_HBM := CreateDIBSection(this.m_Size.Width, this.m_Size.Height)
		this.m_OBM := SelectObject(this.m_HDC, this.m_HBM)
		this.m_Graphics := Gdip_GraphicsFromHDC(this.m_HDC)
	}

	Draw(p_Pos, p_Centered := True)
	{
		if (p_Centered)
			p_Pos := Vector2.Sub(p_Pos, Vector2.Div(this.m_Size, 2))

		if (!this.m_IsDirty and this.m_IsVisible and Vector2.IsEqual(this.m_Pos, p_Pos))
			return

		if (!Vector2.IsEqual(this.m_Pos, p_Pos))
			this.m_Pos := p_Pos.Clone()

		this.DrawGraphic()
		UpdateLayeredWindow(this.m_HWND, this.m_HDC, this.m_Pos.X, this.m_Pos.Y, this.m_Size.Width, this.m_Size.Height)
		Gdip_GraphicsClear(this.m_Graphics)

		this.m_IsDirty := False

		if (this.m_IsVisible)
			return

		Gui, % this.m_Index . ": Show", NA

		this.m_IsVisible := True
	}
	Hide()
	{
		if (!this.m_IsVisible)
			return

		Gui, % this.m_Index . ": Hide"

		this.m_IsVisible := False
	}

	UnloadGraphic()	{
	}

	__Delete()
	{
		this.UnloadGraphic()

		SelectObject(this.m_HDC, this.m_OBM)
		DeleteObject(this.m_HBM)
		DeleteDC(this.m_HDC)
		Gdip_DeleteGraphics(this.m_Graphics)
	}
}
class Line extends Graphic
{
	;TODO Fix size value
	__New(p_StartPos, p_EndPos, p_CanvasSize, p_Color := -1, p_Thickness := 1)
	{
		global

		this.m_StartPos := p_StartPos
		this.m_EndPos := p_EndPos

		this.m_Size := p_CanvasSize

		if (p_Color = -1)
			p_Color := new Color(255, 0, 0, 255)

		this.m_Pen := Gdip_CreatePen(p_Color.GDIP_Hex, p_Thickness)

		base.__New()
	}

	SetDrawingMode()
	{
		Gdip_SetSmoothingMode(this.m_Graphics, 3)
		Gdip_SetInterpolationMode(this.m_Graphics, 5)
	}

	DrawGraphic()
	{
		Gdip_DrawLine(this.m_Graphics, this.m_Pen, this.m_StartPos.X, this.m_StartPos.Y, this.m_EndPos.X, this.m_EndPos.Y)
	}

	UnloadGraphic()
	{
		Gdip_DeletePen(this.m_Pen)
	}
}

class Shape extends Graphic
{
	__New(p_Size, p_Color := -1, p_Filled := True, p_Thickness := 1)
	{
		global

		this.m_Size := p_Size
		this.m_Thickness := p_Thickness

		if (p_Color = -1)
			p_Color := new Color(255, 0, 0, 255)

		if (p_Filled)
			this.m_Brush := Gdip_BrushCreateSolid(p_Color.GDIP_Hex)
		else
			this.m_Pen := Gdip_CreatePen(p_Color.GDIP_Hex, this.m_Thickness)

		base.__New()
	}

	SetDrawingMode()
	{
		Gdip_SetSmoothingMode(this.m_Graphics, 3)
		Gdip_SetInterpolationMode(this.m_Graphics, 5)
	}

	UnloadGraphic()
	{
		if (this.m_Pen)
			Gdip_DeletePen(this.m_Pen)
		if (this.m_Brush)
			Gdip_DeleteBrush(this.m_Brush)
	}
}
class Ellipse extends Shape
{
	DrawGraphic()
	{
		if (this.m_Brush)
			Gdip_FillEllipse(this.m_Graphics, this.m_Brush, 0, 0, this.m_Size.Width, this.m_Size.Height)
		if (this.m_Pen)
			Gdip_DrawEllipse(this.m_Graphics
						, this.m_Pen
						, this.m_Thickness / 2 - 1, this.m_Thickness / 2 - 1
						, this.m_Size.Width - this.m_Thickness, this.m_Size.Height - this.m_Thickness)
	}
}

class Polygon extends Shape
{
	__New(p_Size := -1, p_Color := -1, p_Filled := True, p_Thickness := 1, p_Points*)
	{
		local _min := new Vector2(), _max := new Vector2()

		local _size := p_Size
		if (p_Points.MaxIndex() > 0)
		{
			local i, _point
			for i, _point in p_Points
			{
				if (_point.X < _min.X)
					_min.X := _point.X
				if (_point.Y < _min.Y)
					_min.Y := _point.Y

				if (_point.X > _max.X)
					_max.X := _point.X
				if (_point.Y > _max.Y)
					_max.Y := _point.Y

				this.m_Points .= _point.GDIP_String
				if (i < p_Points.MaxIndex())
					this.m_Points .= "|"
			}

			_size := new Vector2(_max.X - _min.X, _max.Y - _min.Y)
		}

		Debug.Log(p_Filled . " " . p_Thickness)
		base.__New(_size, p_Color, p_Filled, p_Thickness)
	}

	DrawGraphic()
	{
		if (this.m_Brush)
		{
			Gdip_FillPolygon(this.m_Graphics, this.m_Brush, this.m_Points)
		}
		if (this.m_Pen)
			Gdip_DrawLines(this.m_Graphics, this.m_Pen, this.m_Points)
	}

	UpdatePoints(p_Points*)
	{
		global

		this.m_Points := ""

		local i, _point
		for i, _point in p_Points
		{
			this.m_Points .= _point.GDIP_String
			if (i < p_Points.MaxIndex())
				this.m_Points .= "|"
		}

		this.m_IsDirty := True
	}
}

class Image extends Graphic
{
	__New(p_ImagePath, p_Scale := 1, p_Interpolation := 7, p_BackgroundColor := -1)
	{
		global

		this.m_Interpolation := p_Interpolation

		if (p_BackgroundColor != -1)
			this.m_Brush := Gdip_BrushCreateSolid(p_BackgroundColor.GDIP_Hex)

		this.m_Image := Gdip_CreateBitmapFromFile(p_ImagePath)

		this.m_Size
			:= new Vector2(Gdip_GetImageWidth(this.m_Image) * p_Scale
						, Gdip_GetImageHeight(this.m_Image) * p_Scale)

		base.__New()
	}

	SetDrawingMode()
	{
		if (this.m_Brush)
			Gdip_SetCompositingMode(this.m_Graphics, 0)

		Gdip_SetInterpolationMode(this.m_Graphics, this.m_Interpolation)
	}
	DrawGraphic()
	{
		if (this.m_Brush)
			Gdip_FillRectangle(this.m_Graphics, this.m_Brush, 0, 0, this.m_Size.Width, this.m_Size.Height)

		Gdip_DrawImage(this.m_Graphics, this.m_Image, 0, 0, this.m_Size.Width - 1, this.m_Size.Height - 1)
	}

	UnloadGraphic()
	{
		Gdip_DisposeImage(this.m_Image)

		if (this.m_Brush)
			Gdip_DeleteBrush(this.m_Brush)
	}
}