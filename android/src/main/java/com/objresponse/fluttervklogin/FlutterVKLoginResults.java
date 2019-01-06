package com.objresponse.fluttervklogin;

import com.vk.sdk.VKAccessToken;
import com.vk.sdk.api.VKError;

//import java.util.ArrayList;
import java.util.HashMap;
//import java.util.List;
import java.util.Map;

public class FlutterVKLoginResults {
    static final Map<String, String> cancelledByUser = new HashMap<String, String>() {{
        put("status", "cancelledByUser");
    }};

    static Map<String, Object> success(VKAccessToken token) {
        final Map<String, Object> accessTokenMap = FlutterVKLoginResults.accessToken(token);

        return new HashMap<String, Object>() {{
            put("status", "loggedIn");
            put("accessToken", accessTokenMap);
        }};
    }

    static Map<String, String> error(final VKError error) {
        switch (error.errorCode){
            case VKError.VK_API_ERROR:
                return new HashMap<String, String>() {{
                    put("status", "error");
                    put("errorMessage", error.errorMessage);
                }};
            case VKError.VK_CANCELED:
                return cancelledByUser;
        }
        return null;
    }

    static Map<String, Object> accessToken(final VKAccessToken accessToken) {
        if (accessToken == null) {
            return null;
        }

        return new HashMap<String, Object>() {{
            put("token", accessToken.accessToken);
            put("userId", accessToken.userId);
            put("expiresIn", accessToken.expiresIn);
            put("secret", accessToken.secret);
            put("email", accessToken.email);
            put("scope", accessToken.hasScope());
        }};
    }
}