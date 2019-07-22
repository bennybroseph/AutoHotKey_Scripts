
class Event
{
	__New()
	{
		this.m_Listeners := Array()
	}

	AddListener(p_Delegate)
	{
		this.m_Listeners.Push(p_Delegate)
	}

	; RemoveListener() Maybe later...

	Invoke(p_Params*)
	{
		global

		local i, _delegate
		for i, _delegate in this.m_Listeners
			%_delegate%(p_Params)
	}
}

class Delegate
{
	Reference := 0
   	MethodName := ""

	__Call(target, params*)
	{
		if (target == "")
		{
			if (IsObject(this.Reference))
			{
            	invokationTarget := this.Reference
            	return invokationTarget[this.MethodName](params*)
         	}
			else if (IsFunc(this.MethodName))
			{
				dynfunc := this.MethodName
				return dynfunc.(params*)
			}
			else
				msgbox, 16, error, Can't find Invocation Target
		}
	}

	;Creates a new Delegate
	;new Delegate("MyMethod")
	;new Delegate(obj, "MyMemberMethod")
	__New(args*)
	{
		i := 0
		for each, a in args
			i++

		if (i == 1)
			this.MethodName := args[1]
		else
		{
			this.Reference := args[1]
			if(!IsObject(this.Reference))
				throw Exception("When passing 2 Params to Delegate Constructor, the first argument must be a refernece to the Invokation Target Obj!",-1)
         	this.MethodName := args[2]
      	}
	}
}