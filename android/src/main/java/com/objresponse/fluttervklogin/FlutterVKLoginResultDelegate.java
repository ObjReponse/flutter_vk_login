package com.objresponse.fluttervklogin;

import android.content.Intent;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import com.vk.sdk.VKAccessToken;
import com.vk.sdk.VKCallback;
import com.vk.sdk.VKSdk;
import com.vk.sdk.api.VKError;

public class FlutterVKLoginResultDelegate implements VKCallback<VKAccessToken>, PluginRegistry.ActivityResultListener {
    private static final String ERROR_LOGIN_IN_PROGRESS = "login_in_progress";

    private MethodChannel.Result pendingResult;

    void setPendingResult(String methodName, MethodChannel.Result result) {
        if (pendingResult != null) {
            result.error(
                    ERROR_LOGIN_IN_PROGRESS,
                    methodName + " called while another Facebook " +
                            "login operation was in progress.",
                    null
            );
        }

        pendingResult = result;
    }

    @Override
    public void onResult(VKAccessToken res) {
        finishWithResult(FlutterVKLoginResults.success(res));
    }

    @Override
    public void onError(VKError error) {
        finishWithResult(FlutterVKLoginResults.error(error));
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return VKSdk.onActivityResult(requestCode,resultCode, data, this);
    }

    private void finishWithResult(Object result) {
        if (pendingResult != null) {
            pendingResult.success(result);
            pendingResult = null;
        }
    }
}
