using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Scripting;
using Uno.Compiler.ExportTargetInterop;

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

    [Foreign(Language.ObjC)]
    [Require("Xcode.Framework","LocalAuthentication")]
    [Require("Source.Import","LocalAuthentication/LocalAuthentication.h")]
    extern(iOS) void iOSAuth(string reason)
    @{
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:reason
            reply:^(BOOL success, NSError *error) {
                 // Need a pool, since we are running on a different thread
                uAutoReleasePool pool;

                @{iOSFingerPrint:Of(_this).AuthDone(bool, string):Call(success, nil)};
            }];
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            NSLog(@"Could not evaluate policy");
            NSLog(@"%@",[authError localizedDescription]);
            // Should pass string
            @{iOSFingerPrint:Of(_this).AuthDone(bool, string):Call(false, [authError localizedDescription])};
        }
    @}

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
