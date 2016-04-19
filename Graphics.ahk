#include FPS.ahk
#include Gdip.ahk

Class Graphics
{	
	FPS := new FPS(60)
	__New() {		
		if (!this.pToken := Gdip_Startup()) 
		{
			MsgBox, 48, Gdiplus error!, Gdiplus failed to start. Please ensure you have Gdiplus on your system.
			ExitApp
		}
		
		Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
		Gui, 1: Show, NA
		WinSet, ExStyle, +0x20
		this.hwnd1 := WinExist()
		this.hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		this.hdc := CreateCompatibleDC()
		this.obm := SelectObject(this.hdc, this.hbm)
		this.G1 := Gdip_GraphicsFromHDC(this.hdc)
		Gdip_SetSmoothingMode(this.G1, 4)
		
		sFile   := "Target.png"
		Gdip_SetCompositingMode(this.G1,1)
		pBrush := Gdip_BrushCreateSolid(0x0000000)
		Gdip_FillRectangle(this.G1, this.pBrush, 0, 0, A_ScreenWidth, A_ScreenHeight)

		this.pImage    := Gdip_CreateBitmapFromFile(sFile)
		this.ImageW        := Gdip_GetImageWidth(this.pImage)
		this.ImageH        := Gdip_GetImageHeight(this.pImage)
	}
	
	Draw_Target(X, Y) {
		X := X - this.ImageW/2
		Y := Y - this.ImageH/2
		if(!FPS.Get_Sleep())
		{
			Gdip_DrawImage(this.G1, this.pImage, X, Y, this.ImageW, this.ImageH)
			UpdateLayeredWindow(this.hwnd1, this.hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
			Gdip_GraphicsClear(this.G1)
		}
	}
	Hide_Target() {
		if(!FPS.Get_Sleep())
		{
			UpdateLayeredWindow(this.hwnd1, this.hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
			Gdip_GraphicsClear(this.G1)
		}
	}
	
	Delete_Me() {
		Gdip_DeleteBrush(this.pBrush)
		Gdip_DisposeImage(this.pImage)
		
		SelectObject(this.hdc, this.obm)
		DeleteObject(this.hbm)
		DeleteDC(this.hdc)
		Gdip_DeleteGraphics(this.G1)
		Gdip_Shutdown(this.pToken)
	}
}