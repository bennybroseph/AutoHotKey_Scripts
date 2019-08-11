; Contains all graphic items

global GRAPHIC_COUNT := 0

class Graphic
{
	__New()
	{
		global

		local _index := "Image" . ++GRAPHIC_COUNT
		this.m_Index := _index

		this.m_HasDrawn := False
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

	Draw(p_Pos, p_Centered := True)
	{
		if (!this.m_HasDrawn)
		{
			this.DrawGraphic()
			UpdateLayeredWindow(this.m_HWND, this.m_HDC, 0, 0, this.m_Size.Width, this.m_Size.Height)
			this.UnloadGraphic()

			this.m_HasDrawn := True
		}

		if (p_Centered)
			p_Pos := Vector2.Sub(p_Pos, Vector2.Div(this.m_Size, 2))

		if (this.m_IsVisible and Vector2.IsEqual(this.m_Pos, p_Pos))
			return

		if (!Vector2.IsEqual(this.m_Pos, p_Pos))
			this.m_Pos := p_Pos.Clone()

		Gui, % this.m_Index . ": Show", % "x" this.m_Pos.X "y" this.m_Pos.Y "NA"

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
		SelectObject(this.m_HDC, this.m_OBM)
		DeleteObject(this.m_HBM)
		DeleteDC(this.m_HDC)
		Gdip_DeleteGraphics(this.m_HWND)
	}
}
class Line extends Graphic
{
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

class Image extends Graphic
{
	; TODO Add option to ignore smoothing
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