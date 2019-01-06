package com.objresponse.fluttervkloginexample;

import io.flutter.app.FlutterApplication;
import com.vk.sdk.VKSdk;

public class Application extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        this.vkInit();
    }

    public void vkInit(){
        VKSdk.initialize(this);
    }
}
