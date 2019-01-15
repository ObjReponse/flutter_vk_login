package com.objresponse.fluttervklogin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.List;

import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKSdk;
import com.vk.sdk.VKScope;

public class FlutterVkLoginPlugin implements MethodCallHandler {
    private static final String CHANNEL_NAME = "com.objresponse.fluttervklogin/vk_login";

    private static final String LOGIN_ACTION = "login";
    private static final String LOGOUT_ACTION = "logout";
    private static final String GET_CURRENT_ACCESS_TOKEN = "currentAccessToken";

    private static final String SCOPE_ARGUMENT = "scope";

    private final FlutterVKLoginSignInDelegate delegate;

    private final String[] defScope = new String[]{
            VKScope.EMAIL,
            VKScope.NOTIFICATIONS
    };

    FlutterVkLoginPlugin(Registrar registrar){
        delegate = new FlutterVKLoginSignInDelegate(registrar);
    }

    public static void registerWith(Registrar registrar) {
        final FlutterVkLoginPlugin plugin = new FlutterVkLoginPlugin(registrar);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method){
            case LOGIN_ACTION:
                String[] scope = call.argument(SCOPE_ARGUMENT);
                if (scope.length == 0){
                    scope = defScope;
                }
                delegate.logIn(scope, result);
                break;
            case LOGOUT_ACTION:
                delegate.logOut(result);
                break;
            case GET_CURRENT_ACCESS_TOKEN:
                delegate.getCurrentAccessToken(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    public static final class FlutterVKLoginSignInDelegate {
        final Registrar registrar;
        private final FlutterVKLoginResultDelegate resultDelegate;


        FlutterVKLoginSignInDelegate(Registrar registrar){
            this.registrar = registrar;
            this.resultDelegate = new FlutterVKLoginResultDelegate();
            registrar.addActivityResultListener(resultDelegate);
        }

        void logIn(String[] scope, Result result) {
            resultDelegate.setPendingResult(LOGIN_ACTION, result);
            VKSdk.login(registrar.activity(), scope);
        }

        void logOut(Result result){
            VKSdk.logout();
            result.success(null);
        }

        void getCurrentAccessToken(Result result){
            result.success(VKAccessToken.currentToken());
        }
    }
}

