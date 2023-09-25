//
//  AppDelegate.m
//  flutterindia
//
//  Created by admin on 2023/8/17.
//

#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <flutter_boost/FlutterBoost.h>
#import "IndiaFlutterBoostDelegate.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.flutterEngine = [[FlutterEngine alloc] initWithName:@"my flutter engine"];
      // Runs the default Dart entrypoint with a default Flutter route.
    //[self.flutterEngine run];
    // Connects plugins with iOS platform code to this app.
    //[GeneratedPluginRegistrant registerWithRegistry:self.flutterEngine];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    IndiaFlutterBoostDelegate *delegate = [[IndiaFlutterBoostDelegate alloc] initWithEngine:self.flutterEngine];
    UINavigationController *rootVc =[[UINavigationController alloc] init];
    delegate.rootNav = rootVc;
    self.window.rootViewController = rootVc;
    [rootVc setNavigationBarHidden:YES];
    
    FlutterBoostSetupOptions *options = [[FlutterBoostSetupOptions alloc] init];
    options.initalRoute = @"/";
    [FlutterBoost.instance setup:application delegate:delegate callback:^(FlutterEngine *engine) {
        FlutterBoostRouteOptions *routeOptions = [[FlutterBoostRouteOptions alloc] init];
        routeOptions.pageName = @"/";
        [FlutterBoost.instance open:routeOptions];
    } options:options];
    
    return YES;
 }
@end
