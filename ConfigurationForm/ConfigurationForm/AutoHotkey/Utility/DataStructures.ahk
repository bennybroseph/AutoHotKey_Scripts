; Contains multiple data structures including the very basic vector class

class Vector2
{
	__New(p_X := 0, p_Y := 0)
	{
		this.m_X := p_X
		this.m_Y := p_Y
	}

	X[]
	{
		get {
			return this.m_X
		}
		set {
			return this.m_X := value
		}
	}
	Y[]
	{
		get {
			return this.m_Y
		}
		set {
			return this.m_Y := value
		}
	}

	Width[]
	{
		get {
			return this.m_X
		}
		set {
			return this.m_X := value
		}
	}
	Height[]
	{
		get {
			return this.m_Y
		}
		set {
			return this.m_Y := value
		}
	}

	Magnitude[]
	{
		get {
			return Sqrt(this.m_X * this.m_X + this.m_Y * this.m_Y)
		}
	}

	Normalize[]
	{
		get {
			return new Vector2(this.m_X / this.Magnitude, this.m_Y / this.Magnitude)
		}
	}

	String[]
	{
		get{
			return "(" . Round(this.m_X, 2) . ", " . Round(this.m_Y, 2) . ")"
		}
	}

	IsEqual(a, b)
	{
		return a.X = b.X and a.Y = b.Y
	}
}

class LooseStack
{
	__New()
	{
		this.m_Stack := Array()
	}

	Stack[]
	{
		get {
			return this.m_Stack
		}
	}

	Length[]
	{
		get {
			return this.m_Stack.MaxIndex()
		}
	}
	Peek[]
	{
		get {
			return this.m_Stack[this.Length]
		}
	}

	Push(p_Item)
	{
		this.m_Stack.Push(p_Item)
	}
	Remove(p_Item)
	{
		local i, _item
		For i, _item in this.m_Stack
		{
			if (_item = p_Item)
			{
				this.m_Stack.RemoveAt(i)
				return
			}
		}
	}
}

class Color
{
	static s_HexValues := Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")

	__New(p_R, p_G, p_B, p_A := 255)
	{
		global

		this.m_R := p_R
		this.m_G := p_G
		this.m_B := p_B
		this.m_A := p_A

		this.m_HexR := this.ConvertToHex(this.m_R, 2)
		this.m_HexG := this.ConvertToHex(this.m_G, 2)
		this.m_HexB := this.ConvertToHex(this.m_B, 2)
		this.m_HexA := this.ConvertToHex(this.m_A, 2)
	}
	R[]
	{
		get {
			return this.m_R
		}
	}
	G[]
	{
		get {
			return this.m_G
		}
	}
	B[]
	{
		get {
			return this.m_B
		}
	}
	A[]
	{
		get {
			return this.m_A
		}
	}

	Hex[]
	{
		get {
			return "0x" . this.m_HexR . this.m_HexG . this.m_HexB
		}
	}

	GDIP_Hex[]
	{
		get {
			return "0x" . this.m_HexA . this.m_HexR . this.m_HexG . this.m_HexB
		}
	}

	String[]
	{
		get {
			return "(" . this.m_R . ", " . this.m_G . ", " . this.m_B . ", " . this.m_A . ")"
		}
	}
	HexString[]
	{
		get {
			return "(" . this.m_HexR . ", " . this.m_HexG . ", " . this.m_HexB . ", " . this.m_HexA . ")"
		}
	}

	ConvertToHex(p_Decimal, p_MinLength)
	{
		local _result := ""

		local _hex := p_Decimal
		Loop
		{
			local _remainder := Mod(_hex, 16) + 1
			_hex := Floor(_hex / 16)

			_result := this.s_HexValues[_remainder] . _result
		} Until _hex = 0

		While, StrLen(_result) < p_MinLength
			_result .= "0"

		return _result
	}
}