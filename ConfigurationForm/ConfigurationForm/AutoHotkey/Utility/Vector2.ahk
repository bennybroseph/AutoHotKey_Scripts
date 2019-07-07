; Contains the very basic vector class

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