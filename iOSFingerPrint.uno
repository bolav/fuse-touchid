using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;

[Uno.Compiler.ExportTargetInterop.TargetSpecificImplementationAttribute]
public class iOSFingerPrint : NativeModule
{
	public iOSFingerPrint() {
		var i = 0;
		if (i == 1) {
			AuthDone(true, null);
		}
		AddMember(new NativeFunction("auth", (NativeCallback)Authenticate));
	}

	Context Context;
	Fuse.Scripting.Function callback;

	object Authenticate(Context c, object[] args)
	{
		var reason = args[0] as string;
		callback = args[1] as Fuse.Scripting.Function;
		Context = c;
		if defined(iOS) {
			iOSAuth(reason);
		}
		else {
			Context.Dispatcher.Invoke(new InvokeEnclosure(callback, false, "Not on iOS").InvokeCallback);
		}
		return null;
	}

	[Uno.Compiler.ExportTargetInterop.TargetSpecificImplementationAttribute]
	extern(iOS) void iOSAuth(string reason);


	class InvokeEnclosure {
		public InvokeEnclosure (Fuse.Scripting.Function func, bool cbsucc, string cbtext) {
			callback = func;
			callback_succ = cbsucc;
			callback_text = cbtext;
		}
		Fuse.Scripting.Function callback;
		bool callback_succ;
		string callback_text;
		public void InvokeCallback () {
			callback.Call(callback_succ, callback_text);
		}
	}
	void AuthDone (bool auth, string s) {
		Context.Dispatcher.Invoke(new InvokeEnclosure(callback, auth, s).InvokeCallback);
	}

}
