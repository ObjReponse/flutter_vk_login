#import "FlutterVkLoginPlugin.h"
#import <VK-ios-sdk/VKSdk.h>

// ***************************************
// * I'm INCREDIBLY don't how it's works *
// ***************************************

@interface FlutterVkLoginPlugin () <VKSdkUIDelegate>

@end

@implementation FlutterVkLoginPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.objresponse.fluttervklogin/vk_login"
                                     binaryMessenger:[registrar messenger]];
    FlutterVkLoginPlugin* instance = [[FlutterVkLoginPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    [[VKSdk initializeWithAppId:@"6180819"] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    BOOL handled = [VKSdk processOpenURL:url fromApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    return handled;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL handled =
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return handled;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"login" isEqualToString:call.method]) {
        
        // What does `defScope` mean?
        NSArray *defScope = @[@"email"];
        NSArray *scope = call.arguments[@"scope"];
        
        if (scope.count == 0) {
            scope = defScope;
        }
        
        [self logIn:scope result:result];
        
    } else if ([@"logout" isEqualToString:call.method]) {
        [self logOut:result];
    } else if ([@"currentAccessToken" isEqualToString:call.method]) {
        [self getCurrentAccessToken:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)logIn:(NSArray *)scope result:(FlutterResult)result {
    [VKSdk wakeUpSession:scope completeBlock:^(VKAuthorizationState state, NSError *error) {
        
        [self handleLoginResult:state
                         result:result
                          error:error];
    }];
}

- (void)logOut:(FlutterResult)result {
    [VKSdk forceLogout];
    result(nil);
}

- (void)getCurrentAccessToken:(FlutterResult)result {
    VKAccessToken *currentToken = VKSdk.accessToken;
    NSDictionary *mappedToken = [self accessTokenToMap:currentToken];
    
    result(mappedToken);
}


- (void)handleLoginResult:(VKAuthorizationState)loginResult
                   result:(FlutterResult)result
                    error:(NSError *)error {
    if (error == nil) {
        if (loginResult == VKAuthorizationAuthorized) {
            VKAccessToken *token = VKSdk.accessToken;
            NSDictionary *mappedToken = [self accessTokenToMap:token];
            
            result(@{
                @"status" : @"loggedIn",
                @"accessToken" : mappedToken,
            });
        } else {
            result(@{
                @"status" : @"cancelledByUser",
            });
        }
    } else {
        result(@{
            @"status" : @"error",
            @"errorMessage" : [error description],
        });
    }
}

- (id)accessTokenToMap:(VKAccessToken *)accessToken {
    if (accessToken == nil) {
        return [NSNull null];
    }
    
    return @{
        @"token" : accessToken.accessToken,
        @"userId" : accessToken.userId,
        @"expiresIn" : @(accessToken.expiresIn), // without I had error: not obj-c object
        @"secret" : accessToken.secret,
        @"email" : accessToken.email,
        //FIXME: I don't find a way to place `scope` here.
    };
}


@end
