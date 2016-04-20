global PI := 3.141592653589793 ; Define PI for easier use

class System
{
	class Vector2
	{
		; Define member variables. Must be accessed with 'this' keyword
		X := 0.0, Y := 0.0
		
		__New(a_X := 0, a_Y := 0)
		{
			this.X := a_X, this.Y := a_Y
		}
		Set(a_X := 0, a_Y := 0)
		{
			this.X := a_X, this.Y := a_Y
		}
	}
}