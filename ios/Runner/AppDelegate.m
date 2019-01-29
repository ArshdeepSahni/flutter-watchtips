#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"


@implementation WTUserInfoHandler

FlutterEventSink sink;
NSDictionary *info;

- (void) updateUserInfo:(nonnull NSDictionary<NSString *, id> *)userInfo{
    NSLog(@"Update Recieved");
    if(info != userInfo){
        info = userInfo;
        if(sink!=nil){
            sink(@[userInfo]);
        }
    }
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    NSLog(@"Adding Flutter Listener");
    sink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    NSLog(@"Removing Flutter Listener");
    if(sink!=nil){
        sink = nil;
    }
    return nil;
}

@end


@implementation AppDelegate

#pragma mark watch session delegates

// Event triggered when userInfo Rxd
- (void)session:(nonnull WCSession *)session didReceiveUserInfo:(nonnull NSDictionary<NSString *, id> *)userInfo
{
    if(userInfoStreamHandler != nil){
        [userInfoStreamHandler updateUserInfo:userInfo];
    }
}




#pragma mark watch session methods

// Method used to enable the Watch session
- (void)activateSession
{
    [self activateChannel];
    [self watchSession];
}

// create our eventChannel
-(FlutterEventChannel *) activateChannel {
    NSLog(@"activateChannel");
    userInfoStreamHandler = [[WTUserInfoHandler alloc] init];
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"uk.spiralarm.watchtips/tipinfo/watchdata" binaryMessenger:controller];
    [eventChannel setStreamHandler:(NSObject<FlutterStreamHandler> * _Nullable) userInfoStreamHandler ];
    return eventChannel;
}


// activate session
- (WCSession *)watchSession
{
    if (watchSession == nil) {
        if ([WCSession isSupported]) {
            watchSession = [WCSession defaultSession];
            [watchSession setDelegate:self];
            [watchSession activateSession];
        } else {
            NSLog(@"Error -  Watch Connectivity NOT supported");
        }
    }
    return watchSession;
}
- (void)dealloc
{
    if (watchSession != nil) {
        [watchSession setDelegate:nil];
    }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel *tipinfoChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"uk.spiralarm.watchtips/tipinfo"
                                            binaryMessenger:controller];
    
    //__weak typeof(self) weakSelf = self;
    [tipinfoChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        
        // activate Session
        if([@"activateSession" isEqualToString:call.method]){
            [self activateSession];
            result(@"WatchTips Activated");
        }
        
    }];
    
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
