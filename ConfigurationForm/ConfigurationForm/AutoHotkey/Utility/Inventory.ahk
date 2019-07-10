; Contains functionality related to the inventory grid

class Inventory
{
	static __singleton :=
	static __init := False

	Init()
	{
		global

		this.__singleton := new Inventory()

		Debug.AddToOnTooltip(new Delegate(Inventory, "OnTooltip"))

		this.__init := True
	}

	__New()
	{
		global

		this.m_Enabled := False

		this.m_Pos := new Vector2(1, 1)
		this.m_Grid := InventoryGrids.CreateGrid()

		Debug.AddToLog(this.m_Grid.MaxIndex())
		Debug.AddToLog(this.m_Grid[1].MaxIndex())

		this.m_ControlStack := new LooseStack()

		this.m_ShowInventoryModeNotification
			:= IniReader.ReadProfileKey(ProfileSection.Preferences, "Show_Inventory_Mode_Notification")
		this.m_BaseResolution := new Vector2(1920, 1080)
	}

	Enabled[]
	{
		get {
			return this.__singleton.m_Enabled
		}
	}

	Pos[]
	{
		get {
			return this.__singleton.m_Pos
		}
	}
	MaxPos[]
	{
		get {
			return new Vector2(this.__singleton.m_Grid.MaxIndex(), this.__singleton.m_Grid[1].MaxIndex())
		}
	}

	ControlStack[]
	{
		get {
			return this.__singleton.m_ControlStack
		}
	}

	ShowInventoryModeNotification[]
	{
		get {
			return this.__singleton.m_ShowInventoryModeNotification
		}
	}

	BaseResolution[]
	{
		get {
			return this.__singleton.m_BaseResolution
		}
	}

	GetGridPos(p_X := 0, p_Y := 0)
	{
		global

		if (p_X = 0)
			p_X := this.Pos.X
		if (p_Y = 0)
			p_Y := this.Pos.Y

		local _gridPos := new Vector2(this.__singleton.m_Grid[p_X, p_Y].X, this.__singleton.m_Grid[p_X, p_Y].Y)
		_gridPos.X := _gridPos.X * (Graphics.ActiveWinStats.Size.Width / this.BaseResolution.Width)
		_gridPos.Y := _gridPos.Y * (Graphics.ActiveWinStats.Size.Height / this.BaseResolution.Height)

		return _gridPos
	}

	PressControl(p_ControlIndex)
	{
		global

		local _prevGridPos := new Vector2(this.GetGridPos().X, this.GetGridPos().Y)
		Loop
		{
			if (p_ControlIndex = ControlIndex.DPadUp)
				this.Pos.Y--
			if (p_ControlIndex = ControlIndex.DPadDown)
				this.Pos.Y++
			if (p_ControlIndex = ControlIndex.DPadLeft)
				this.Pos.X--
			if (p_ControlIndex = ControlIndex.DPadRight)
				this.Pos.X++

			if (this.Pos.X < 1)
				this.Pos.X := this.MaxPos.X
			if (this.Pos.X > this.MaxPos.X)
				this.Pos.X := 1

			if (this.Pos.Y < 1)
				this.Pos.Y := this.MaxPos.Y
			if (this.Pos.Y > this.MaxPos.Y)
				this.Pos.Y := 1
		} Until (this.GetGridPos().X != _prevGridPos.X
			or this.GetGridPos().Y != _prevGridPos.Y)

		InputHelper.MoveMouse(this.GetGridPos())
	}
	HoldControl(p_ControlIndex)
	{
		Debug.AddToLog("Pushed " . p_ControlIndex . " into Inventory stack")
		this.ControlStack.Push(p_ControlIndex)
	}
	ReleaseControl(p_ControlIndex)
	{
		Debug.AddToLog("Removed " . p_ControlIndex . " from Inventory stack")
		this.ControlStack.Remove(p_ControlIndex)
	}

	ProcessControlStack()
	{
		global

		local i, _controlIndex
		For i, _controlIndex in this.ControlStack.Stack
			this.PressControl(_controlIndex)
	}

	Toggle()
	{
		if (!this.Enabled)
			this.Enable()
		else
			this.Disable()
	}
	Enable()
	{
		global

		if (Controller.CursorMode)
			Controller.DisableCursorMode()

		if (this.ShowInventoryModeNotification)
		{
			local _controlInfo := Controller.FindControlInfo(IniReader.ParseKeybind("Inventory"))

			Tooltip, % "Inventory Mode: Enabled `n"
					. _controlInfo.Act . " the " . _controlInfo.Control.Name . " button on the controller to disable", 0, 0, 1
		}

		IniHelper.ReleaseKeybind(Controller.MoveOnlyKey)
		InputHelper.MoveMouse(this.GetGridPos())

		this.Enabled := True
	}
    Disable()
    {
		global
		if (this.ShowInventoryModeNotification)
			Tooltip, , , , 1

		this.Enabled := False
    }

	OnTooltip()
	{
		global

		local _debugText := _debugText . "Inventory - " . this.Enabled . " Pos: (" . this.Pos.X . ", " . this.Pos.Y . ") "
						. "Value: (" . this.GetGridPos().X . ", " . this.GetGridPos().Y . ")"

		return _debugText
	}
}

class InventoryGrids
{
	CreateGrid(p_Type := "Diablo III")
	{
		local _newGrid := Array()

		if (p_Type = "Diablo III")
		{
			; Base Inventory Grid
			Loop, 10
			{
				i := A_Index
				Loop, 6
					_newGrid[i, A_Index + 5] := new Vector2(1428.5 + 50 * (i - 1), 583.5 + 50 * (A_Index - 1))
			}

			; The two UI buttons "Paragon" and "Details"
			Loop, 4
			{
				i := A_Index
				Loop, 5
				{
					if(A_Index > 2)
						_newGrid[i, A_Index] := new Vector2(1524.5, 511)
					else
						_newGrid[i, A_Index] := new Vector2(1524.5,  223)
				}
			}

			; Weapon
			_newGrid[5, 5] := new Vector2(1641.5, 476)
			_newGrid[6, 5] := _newGrid[5, 5]
			_newGrid[5, 4] := _newGrid[5, 5]
			_newGrid[6, 4] := _newGrid[5, 5]

			; Left Ring
			_newGrid[5, 4] := new Vector2(1641.5, 387.5)
			_newGrid[6, 4] := _newGrid[5, 4]

			; Hands
			_newGrid[5, 3] := new Vector2(1641.5, 318)
			_newGrid[6, 3] := _newGrid[5, 3]

			; Shoulders
			_newGrid[5, 2] := new Vector2(1665, 229)
			_newGrid[6, 2] := _newGrid[5, 2]
			_newGrid[5, 1] := _newGrid[5, 2]
			_newGrid[6, 1] := _newGrid[5, 2]

			; Feet
			_newGrid[7, 5] := new Vector2(1739, 494.5)
			_newGrid[8, 5] := _newGrid[7, 5]

			; Legs
			_newGrid[7, 4] := new Vector2(1739, 412)
			_newGrid[8, 4] := _newGrid[7, 4]

			; Waist
			_newGrid[7, 3] := new Vector2(1739, 353)
			_newGrid[8, 3] := _newGrid[7, 3]

			; Chest
			_newGrid[7, 2] := new Vector2(1739, 282)
			_newGrid[8, 2] := _newGrid[7, 2]

			; Head
			_newGrid[7, 1] := new Vector2(1739, 199)
			_newGrid[8, 1] := _newGrid[7, 1]

			; Off-Hand
			_newGrid[9,  5] := new Vector2(1836, 476)
			_newGrid[10, 5] := _newGrid[9, 5]
			_newGrid[9,  4] := _newGrid[9, 5]
			_newGrid[10, 4] := _newGrid[9, 5]

			; Right Ring
			_newGrid[9,  4] := new Vector2(1836.5, 387.5)
			_newGrid[10, 4] := _newGrid[9, 4]

			; Wrists
			_newGrid[9,  3] := new Vector2(1836, 318)
			_newGrid[10, 3] := _newGrid[9, 3]

			; Amulet
			_newGrid[9,  2] := new Vector2(1808.5, 232.5)
			_newGrid[10, 2] := _newGrid[9,  2]
			_newGrid[9,  1] := _newGrid[9,  2]
			_newGrid[10, 1] := _newGrid[9,  2]
		}

		return _newGrid
	}
}