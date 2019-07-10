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