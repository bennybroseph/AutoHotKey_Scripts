; Contains multiple data structures including the vector, rect and color class

Clamp(a, min, max)
{
	local _result := a

	_result := Max(_result, min)
	_result := Min(_result, max)

	return _result
}

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
			return Vector2.Div(this, this.Magnitude)
		}
	}

	String[]
	{
		get{
			return "(" . Round(this.m_X, 2) . ", " . Round(this.m_Y, 2) . ")"
		}
	}

	IsEqual(a, b, dec := 2)
	{
		return Round(a.X, dec) = Round(b.X, dec) and Round(a.Y, dec) = Round(b.Y, dec)
	}

	Negative()
	{
		local _result := this.Clone()

		_result.m_X := -_result.m_X
		_result.m_Y := -_result.m_Y

		return _result
	}
	Reciprocal()
	{
		local _result := this.Clone()

		_result.m_X := 1 / _result.m_X
		_result.m_Y := 1 / _result.m_Y

		return _result
	}

	Add(a, b)
	{
		local _result := a.Clone()
		if b is Number
		{
			_result.X += b
			_result.Y += b
		}
		else
		{
			_result.X += b.X
			_result.Y += b.Y
		}

		return _result
	}
	Sub(a, b)
	{
		if b is Number
			return Vector2.Add(a, -b)

		return Vector2.Add(a, b.Negative())
	}

	Mul(a, b)
	{
		local _result := a.Clone()
		if b is Number
		{
			_result.X *= b
			_result.Y *= b
		}
		else
		{
			_result.X *= b.X
			_result.Y *= b.Y
		}

		return _result
	}
	Div(a, b)
	{
		if b is Number
			return Vector2.Mul(a, 1 / b)

		return Vector2.Mul(a, b.Reciprocal())
	}

	Clamp(a, min, max)
	{
		local _result := a.Clone()

		if (min is Number and max is Number)
		{
			_result.X := Clamp(_result.X, min, max)
			_result.Y := Clamp(_result.Y, min, max)
		}
		else
		{
			_result.X := Clamp(_result.X, min.X, max.X)
			_result.Y := Clamp(_result.Y, min.Y, max.Y)
		}

		return _result
	}
}

class Rect
{
	__New(p_Min := -1, p_Max := -1)
	{
		if (p_Min = -1)
			p_Min := new Vector2()
		if (p_Max = -1)
			p_Max := new Vector2()

		this.m_Min := p_Min
		this.m_Max := p_Max
	}

	Min[]
	{
		get {
			return this.m_Min
		}
		set {
			return this.m_Min := value
		}
	}
	Max[]
	{
		get {
			return this.m_Max
		}
		set {
			return this.m_Max := value
		}
	}

	Size[]
	{
		get {
			return Vector2.Sub(this.m_Max, this.m_Min)
		}
	}

	Center[]
	{
		get {
			return Vector2.Add(this.m_Min, Vector2.Div(this.Size, 2))
		}
	}

	String[]
	{
		get {
			return "Min: " . this.m_Min.String . " Max: " . this.m_Max.String
		}
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