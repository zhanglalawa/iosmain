//
//  FlutterBoostDelegate.m
//  flutterindia
//
//  Created by admin on 2023/8/18.
//

#import "IndiaFlutterBoostDelegate.h"
#import <FBFlutterContainer.h>
#import <FBFlutterViewContainer.h>
#import <Flutter/Flutter.h>
#import "FaceViewController.h"
@interface IndiaFlutterBoostDelegate(){
    NSMutableDictionary<NSString*, void(^)(NSDictionary*)> *_resultTable;
}
@end
@implementation IndiaFlutterBoostDelegate

- (instancetype)initWithEngine: (FlutterEngine *)engine{
    self = [super init];
    if (self) {
        _rootNav = [[UINavigationController alloc] init];
        _resultTable = [[NSMutableDictionary alloc] init];
        self.flutterEngine = engine;
    }
    return self;
}
- (void)popRoute:(FlutterBoostRouteOptions *)options {
    UIViewController *currVC = self.rootNav.presentedViewController;
    if ([currVC isKindOfClass:[FBFlutterViewContainer class]]){
        FBFlutterViewContainer *fbVC = (FBFlutterViewContainer *) currVC;
        if([fbVC.uniqueId isEqualToString:options.uniqueId] &&(fbVC.modalPresentationStyle == UIModalPresentationOverFullScreen)){
            [self.rootNav.topViewController beginAppearanceTransition:YES animated:NO];
            [currVC dismissViewControllerAnimated:YES completion:^{
                [self.rootNav.topViewController endAppearanceTransition];
            }];
        }else {
            [currVC dismissViewControllerAnimated:YES completion:nil];
        }
    }else {
        [self.rootNav popViewControllerAnimated:YES];
    }
    
    void(^onPageFinished)(NSDictionary*) = [_resultTable objectForKey:options.pageName];
    if (onPageFinished){
        onPageFinished(options.arguments);
        [_resultTable removeObjectForKey:options.pageName];
    }
}

- (void)pushFlutterRoute:(FlutterBoostRouteOptions *)options {
    FBFlutterViewContainer *fbVC  = FBFlutterViewContainer.new;
    [fbVC setName:options.pageName uniqueId:options.uniqueId params:options.arguments opaque:options.opaque];
    
    BOOL isPresent = [options.arguments[@"isPresent"] isKindOfClass:[NSNumber class]] ? [options.arguments[@"isPresent"] boolValue] : NO;
    BOOL isAnimated = [options.arguments[@"isAnimated"] isKindOfClass:[NSNumber class]] ? [options.arguments[@"isAnimated"] boolValue] : YES;
    if (options.onPageFinished) {
        [_resultTable setObject:options.onPageFinished forKey:options.pageName];
    }
    
    if (isPresent || !options.opaque){
        [self.rootNav presentViewController:fbVC animated:isAnimated completion:nil];
    }else {
        [self.rootNav pushViewController:fbVC animated:isAnimated];
    }
}

- (void)pushNativeRoute:(NSString *)pageName arguments:(NSDictionary *)arguments {
    NSLog(@"pushNativeRoute" );
    BOOL isPresent = [arguments[@"isPresent"] isKindOfClass:[NSNumber class]] ? [arguments[@"isPresent"] boolValue] : NO;
    BOOL isAnimated = [arguments[@"isAnimated"] isKindOfClass:[NSNumber class]] ? [arguments[@"isAnimated"] boolValue] : YES;
    
    if ([@"face" isEqualToString:pageName]) {
        [self.rootNav pushViewController:[[FaceViewController alloc] init] animated:isAnimated];
    }
}

- (FlutterEngine*) engine {
    return self.flutterEngine;
}

@end
