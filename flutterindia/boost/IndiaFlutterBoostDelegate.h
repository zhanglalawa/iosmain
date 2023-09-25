//
//  FlutterBoostDelegate.h
//  flutterindia
//
//  Created by admin on 2023/8/18.
//

#import <Foundation/Foundation.h>
#import <flutter_boost/FlutterBoost.h>
#import <FlutterBoostDelegate.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface IndiaFlutterBoostDelegate : NSObject<FlutterBoostDelegate>
@property (nonatomic) UINavigationController *rootNav;
@property(nonatomic) FlutterEngine *flutterEngine;

- (instancetype)initWithEngine: (FlutterEngine *)engine;
@end

NS_ASSUME_NONNULL_END
